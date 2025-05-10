
#!/usr/bin/env bash

# Stop on error
set -e

# --- Configuration ---

# Packages from official repositories (ADD iptables-nft here)
PACMAN_PACKAGES=(
    blueman
    bluez-utils # Often needed with blueman
    btop
    # catppuccin-gtk-theme-mocha # This is AUR
    ccache
    cmake
    curl
    dfu-util
    docker
    docker-buildx
    docker-compose
    dtc
    efibootmgr
    exfatprogs
    fcitx5
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-qt
    fcitx5-bamboo
    # fcitx5-mozc # Keep if you need Japanese input
    fd
    firefox
    fish
    fuse-overlayfs
    fuse2 # For AppImages/older software
    fzf
    git
    # Add GNOME packages ONLY if you intend to install GNOME Desktop
    # gdm gnome-shell gnome-control-center nautilus etc...
    # If only using Hyprland, remove GNOME packages to avoid conflicts/bloat
    gparted
    gperf # Build tool, often needed
    hyprland
    hyprlock
    hyprpaper
    intel-ucode # Or amd-ucode
    jq
    # kicad # Large install, keep if needed
    kitty
    # lazydocker # This is AUR: lazydocker
    lazygit
    linux
    linux-firmware
    linux-headers
    # loupe # GNOME image viewer
    # malcontent # GNOME parental controls
    minicom
    nano
    neovim
    # nerdfetch # This is AUR
    networkmanager # Essential for networking
    ninja
    ntfs-3g
    # nvidia nvidia-settings # Keep ONLY if you have NVIDIA hardware
    # nvm # Installed via script
    nwg-look
    # orca # Screen reader
    pavucontrol
    pipewire-alsa
    pipewire-jack
    # pod2man # Provided by perl package
    python-pip
    python-pipx
    ripgrep
    # rygel # GNOME media server
    # simple-scan # Scanner utility
    # snapshot # GNOME camera app
    starship
    stow
    # sushi # Nautilus previewer
    # tecla # GNOME accessibility
    terraform
    # tio # This is AUR
    # totem # GNOME video player
    tree
    ttf-cascadia-code-nerd
    usbutils
    vlc
    waybar
    wget
    wl-clipboard
    wlsunset
    wofi
    # xdg-desktop-portal-gnome # Keep if using GNOME apps heavily on Hyprland, or install xdg-desktop-portal-hyprland
    xdg-user-dirs-gtk # Creates standard user directories (Downloads, etc.)
    yazi
    # yelp # GNOME help browser
    zip
    zoxide
    zram-generator
    # Add base-devel and git if not already assumed to be present
    base-devel
    git
    # 7zip # Official package name is p7zip
    p7zip
    # ARM/AVR tools if needed
    arm-none-eabi-gcc
    arm-none-eabi-newlib
    avr-gcc
    avr-libc
    # JDK if needed
    jdk17-openjdk # Or other versions like jdk-openjdk
)

# Packages from the AUR (Arch User Repository)
AUR_PACKAGES=(
    catppuccin-gtk-theme-mocha
    google-chrome
    lazydocker
    nerdfetch
    termius-bin # Use the -bin version
    tio
    # android-studio # Large install, keep if needed
    # yay-debug # Usually not needed
)


# Function to print messages
log() {
    echo ">>> $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Script Start ---

log "Starting Arch Linux package installation script..."

# Check if running as root, warn if so
if [[ $EUID -eq 0 ]]; then
   log "WARNING: It's generally recommended to run this script as a regular user."
   log "         It will use 'sudo' when needed. Running as root might cause issues,"
   log "         especially with AUR helpers like yay."
   sleep 3
fi

# Ensure sudo is available
if ! command_exists sudo; then
    log "ERROR: 'sudo' command not found. Please install sudo."
    exit 1
fi

# Ask for confirmation
read -p "This script will install/update packages using pacman and yay. Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    log "Installation aborted."
    exit 0
fi

# --- System Update ---
log "Updating system repositories and packages..."
sudo pacman -Syu --noconfirm

# --- Install Prerequisites (base-devel, git, curl, wget) ---
# Although included in PACMAN_PACKAGES list, ensure they are installed early.
log "Ensuring essential tools (git, base-devel, curl, wget) are installed..."
sudo pacman -S --needed --noconfirm git base-devel curl wget
# --- System Update ---
log "Updating system repositories and packages..."
# Check lock file before sync
PACMAN_LOCK="/var/lib/pacman/db.lck"
if [ -f "$PACMAN_LOCK" ]; then
    log "ERROR: Pacman lock file exists: $PACMAN_LOCK. Resolve conflict and re-run."
    exit 1
fi
sudo pacman -Syu --noconfirm


# --- Install Official Packages ---
log "Installing packages from official repositories..."

# Check lock file again before installing
if [ -f "$PACMAN_LOCK" ]; then
    log "ERROR: Pacman lock file exists: $PACMAN_LOCK. Resolve conflict and re-run."
    exit 1
fi

# Combine hardcoded list with pkglist.txt for OFFICIAL packages
declare -A official_packages_seen
declare -a FINAL_PACMAN_LIST

# Add hardcoded official packages
for pkg in "${PACMAN_PACKAGES[@]}"; do
    if [[ -z "${official_packages_seen[$pkg]}" ]]; then
        FINAL_PACMAN_LIST+=("$pkg")
        official_packages_seen[$pkg]=1
    fi
done

# Add official packages from pkglist.txt
if [[ -f "pkglist.txt" ]]; then
    log "Reading official packages from pkglist.txt"
    mapfile -t file_pkgs < <(grep -vE '^\s*(#|$)' pkglist.txt | sed 's/#.*//' | xargs)
    for pkg in "${file_pkgs[@]}"; do
        # Only add if not already seen
        if [[ -z "${official_packages_seen[$pkg]}" ]]; then
            FINAL_PACMAN_LIST+=("$pkg")
            official_packages_seen[$pkg]=1
        fi
    done
fi

# Install OFFICIAL Packages
if [ ${#FINAL_PACMAN_LIST[@]} -gt 0 ]; then
    pacman_pkg_list="${FINAL_PACMAN_LIST[*]}"
    log "Attempting to install/update via Pacman: ${pacman_pkg_list}"
    # Use --askconfirm instead of --noconfirm if you want to manually resolve conflicts like iptables
    # Or rely on having added iptables-nft above
    if sudo pacman -S --needed --noconfirm ${pacman_pkg_list}; then
        log "Official package installation command finished successfully."
    else
        log "WARNING: Pacman command finished with errors. Some official packages might not have been found or installed."
        log "Check the pacman output above."
        # Decide whether to exit: exit 1
    fi
else
    log "No official packages specified or found to install."
fi


# --- Install AUR Packages ---
log "Installing packages from the AUR..."

# Combine hardcoded list with aur-pkglist.txt for AUR packages
declare -A aur_packages_seen
declare -a FINAL_AUR_LIST

# Add hardcoded AUR packages
for pkg in "${AUR_PACKAGES[@]}"; do
    if [[ -z "${aur_packages_seen[$pkg]}" ]]; then
        FINAL_AUR_LIST+=("$pkg")
        aur_packages_seen[$pkg]=1
    fi
done

# Add AUR packages from aur-pkglist.txt
if [[ -f "aur-pkglist.txt" ]]; then
    log "Reading AUR packages from aur-pkglist.txt"
    mapfile -t file_aur_pkgs < <(grep -vE '^\s*(#|$)' aur-pkglist.txt | sed 's/#.*//' | xargs)
    for pkg in "${file_aur_pkgs[@]}"; do
         # Only add if not already seen AND not a known non-AUR package
         if [[ -z "${aur_packages_seen[$pkg]}" && "$pkg" != "nvm" && "$pkg" != "yay" && "$pkg" != "pod2man" ]]; then
            FINAL_AUR_LIST+=("$pkg")
            aur_packages_seen[$pkg]=1
        fi
    done
fi

# Install AUR Packages
if [ ${#FINAL_AUR_LIST[@]} -gt 0 ]; then
    aur_pkg_list="${FINAL_AUR_LIST[*]}"
    log "Attempting to install/update via Yay: ${aur_pkg_list}"
    # !!! CRITICAL: NO SUDO HERE !!!
    if yay -S --needed --noconfirm ${aur_pkg_list}; then
         log "AUR package installation command finished successfully."
    else
         log "ERROR: Yay command failed. Please check the output above for errors."
         exit 1 # Exit if yay fails
    fi
else
    log "No AUR packages specified or found to install."
fi





# --- Ensure Rust is up ---
log "Install rust and rust deps"
sudo pacman -S rustup
rustup default stable




# --- Install nvm (Node Version Manager) ---
# (Keep the existing NVM installation section as is - the fish plugin usually wraps the core NVM)
if ! command_exists nvm; then
    log "Installing nvm (Node Version Manager)..."
    NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
    curl -o- "$NVM_INSTALL_URL" | bash
    log "nvm installation script executed."
    log "IMPORTANT: You NEED TO RESTART your shell or source your shell's rc file"
    log "           for the 'nvm' command to become available in Bash/Zsh."
    log "           The fish nvm plugin will handle loading it within Fish."
else
     log "nvm appears to be installed or sourced already."
fi


# --- Configure Fish Shell ---
log "-----------------------------------------------------"
log "Configuring Fish Shell..."
log "-----------------------------------------------------"

if command_exists fish; then
    log "Fish shell is installed. Proceeding with Fisher setup."

    # Install Fisher and specified plugins
    # Run these commands *as the user* within a fish subshell
    log "Installing Fisher plugin manager and plugins (z, nvm.fish)..."
    # Note: The user's original command includes installing fisher itself again, which is fine.
    # Using 'and' is Fish idiomatic way to chain commands on success.
    if fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher; and fisher install jethrokuan/z; and fisher install jorgebucaran/nvm.fish'; then
        log "Fisher and plugins (z, nvm.fish) installation commands executed."
        log "You may need to restart Fish shell for all changes to take effect."
    else
        log "ERROR: Failed to install Fisher or its plugins. Check output above."
        # Decide if this error should be fatal
        # exit 1
    fi

    # Setting default shell - Advise manual execution
    log "-----------------------------------------------------"
    log "IMPORTANT: To set Fish as your default shell, run the following command"
    log "           manually after this script finishes and enter your password:"
    log ""
    log "  chsh -s /usr/bin/fish"
    log ""
    log "You will need to log out and log back in for the default shell change to take effect."
    log "-----------------------------------------------------"

else
    log "WARNING: Fish shell command not found. Skipping Fisher setup."
    log "         Ensure 'fish' was included in PACMAN_PACKAGES and installed correctly."
fi


# --- Copy Configuration Files/Folders ---
log "-----------------------------------------------------"
log "Copying configuration files/folders..."
log "-----------------------------------------------------"

CONFIG_DEST="$HOME/.config"
CURRENT_DIR=$(pwd) # Get the directory where the script was executed

log "Checking for configuration directories (like 'hypr/hypr', 'nvim/nvim') in: $CURRENT_DIR"
log "Target destination: $CONFIG_DEST"

# Ensure the target ~/.config directory exists
if [ ! -d "$CONFIG_DEST" ]; then
    log "Creating destination directory: $CONFIG_DEST"
    mkdir -p "$CONFIG_DEST"
fi

shopt -s nullglob # Prevent loop from running if no matches are found
shopt -s dotglob # Ensure dotfiles (like .config) inside source dirs are copied

# Iterate through items in the current directory
for top_level_item in "$CURRENT_DIR"/*; do
    # Check if the item is a directory
    if [ -d "$top_level_item" ]; then
        top_level_name=$(basename "$top_level_item")

        # Check if a directory with the *same name* exists *inside* this directory
        inner_config_dir="$top_level_item/$top_level_name"
        if [ -d "$inner_config_dir" ]; then
            target_dir="$CONFIG_DEST/$top_level_name"
            log "Found config structure: '$top_level_name/$top_level_name'. Copying contents to '$target_dir/'"

            # Create the target directory in ~/.config if it doesn't exist
            mkdir -p "$target_dir"

            # Copy the *contents* of the inner directory to the target directory
            # Using 'cp -a source/. dest/' is a common pattern for this.
            if cp -ar "$inner_config_dir/." "$target_dir/"; then
                log " -> Successfully copied contents of '$inner_config_dir' to '$target_dir/'"
            else
                log "ERROR: Failed to copy contents from '$inner_config_dir' to '$target_dir/'."
                # Exit or continue based on preference (set -e should handle exit)
            fi

            # Special handling note for backgrounds if needed - this logic copies it to ~/.config/backgrounds
            if [[ "$top_level_name" == "backgrounds" ]]; then
                 log "NOTE: Copied 'backgrounds/backgrounds/*' to '$CONFIG_DEST/backgrounds/'. You might want to move these images elsewhere (e.g., ~/Pictures/Wallpapers)."
            fi
        else
            log "Skipping '$top_level_name': No inner directory named '$top_level_name' found inside."
        fi
    fi
done # End outer loop (top_level_item)

shopt -u nullglob dotglob # Turn off the shell options

log "Finished copying configuration files/folders."

# --- Finished ---
log "-----------------------------------------------------"
log " Installation and Setup Script Finished!"
log "-----------------------------------------------------"
log ""
log "Post-operation Notes:"
# (Keep existing notes and add/modify Fish-specific ones)
log " *  Configuration Files: Copied contents from '$CURRENT_DIR/dirname/dirname/' to '$CONFIG_DEST/dirname/' for relevant directories."
log " *  Backgrounds: Image files from '$CURRENT_DIR/backgrounds/backgrounds/' were copied to '$CONFIG_DEST/backgrounds/'. Consider moving them."
log " *  Fish Shell & Fisher:"
log "    - Fisher plugin manager and plugins (z, nvm.fish) were installed."
log "    - TO MAKE FISH YOUR DEFAULT SHELL: Run 'chsh -s /usr/bin/fish' manually and enter your password."
log "    - Log out and log back in for the default shell change to apply."
log "    - You might need to start a new Fish shell instance for plugin functions to be fully available."
log " *  NVM: Remember to RESTART YOUR SHELL (or source rc files for Bash/Zsh). For Fish, the nvm.fish plugin should handle loading NVM automatically in new Fish sessions."
log "    - After restarting/sourcing, install Node.js with 'nvm install node'."
log " *  Fcitx5: Enable by setting environment variables (export GTK_IM_MODULE=fcitx, etc.) and potentially starting the 'fcitx5' daemon. Log out/in may be required."
log " *  Starship: Add 'starship init fish | source' to your ~/.config/fish/config.fish and restart the shell."
log " *  PipeWire: Ensure services are running ('systemctl --user status pipewire pipewire-pulse wireplumber')."
log " *  Review Logs: Check the script output above for any errors."
log ""
log "Enjoy your new setup!"

exit 0
