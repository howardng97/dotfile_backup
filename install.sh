#!/usr/bin/env bash

# Stop on error
set -e

# Store the current working directory
SCRIPT_CWD=$(pwd)

# --- Configuration ---

# Packages from official repositories
PACMAN_PACKAGES=(
    base-devel # Essential build tools, git is separate but also key
    git # Essential for AUR and development
    blueman
    bluez # Group: includes bluez-libs, bluez-utils. Good for Bluetooth functionality.
    # bluez-utils # Covered by bluez group
    btop
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
    # Add GNOME packages ONLY if you intend to install GNOME Desktop
    # gdm gnome-shell gnome-control-center nautilus etc...
    # If only using Hyprland, remove GNOME packages to avoid conflicts/bloat
    gparted
    gperf # Build tool, often needed
    hyprland
    hyprlock
    hyprpaper
    hyprshot hyprsunset
    intel-ucode # Or amd-ucode
    iptables-nft # Added as per script's original comment
    jq
    # kicad # Large install, keep if needed
    kitty
    lazygit
    linux
    linux-firmware
    linux-headers
    # loupe # GNOME image viewer
    # malcontent # GNOME parental controls
    minicom
    nano
    neovim
    networkmanager # Essential for networking
    ninja
    ntfs-3g
    # nvidia nvidia-settings # Keep ONLY if you have NVIDIA hardware
    # nvm # Installed via script later
    nwg-look
    # orca # Screen reader
    p7zip # Official name for 7zip
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
    postman-bin
    another-redis-desktop-manager-appimage
    # android-studio # Large install, keep if needed
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
   log "         especially with AUR helpers like yay and building packages."
   log "         'makepkg' (used for AUR packages) should not be run as root."
   read -p "Do you want to continue as root? (y/N): " continue_as_root
   if [[ ! "$continue_as_root" =~ ^[Yy]$ ]]; then
       log "Aborting. Please run as a non-root user."
       exit 1
   fi
fi

# Ensure sudo is available
if ! command_exists sudo; then
    log "ERROR: 'sudo' command not found. Please install sudo."
    exit 1
fi

# Ask for confirmation
read -p "This script will install/update packages using pacman and an AUR helper. Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    log "Installation aborted."
    exit 0
fi

# --- System Update ---
log "Updating system repositories and packages..."
PACMAN_LOCK="/var/lib/pacman/db.lck"
if [ -f "$PACMAN_LOCK" ]; then
    log "ERROR: Pacman lock file exists: $PACMAN_LOCK. Please resolve the conflict (e.g., wait for another pacman process to finish, or remove the lock file if you are sure it's stale: sudo rm $PACMAN_LOCK) and re-run."
    exit 1
fi
sudo pacman -Syu --noconfirm

# --- Install Prerequisites (base-devel, git, curl, wget) ---
# Although included in PACMAN_PACKAGES list, ensure they are installed early.
log "Ensuring essential tools (git, base-devel, curl, wget) are installed..."
sudo pacman -S --needed --noconfirm git base-devel curl wget

# --- Install AUR Helper (yay) ---
if ! command_exists yay; then
    log "AUR helper (yay) not found. Attempting to install it..."
    if [[ $EUID -eq 0 ]]; then
        log "ERROR: Cannot build 'yay' as root. Please run this script as a regular user."
        exit 1
    fi

    # Create a temporary directory for building yay
    YAY_BUILD_DIR=$(mktemp -d)
    log "Cloning yay repository into $YAY_BUILD_DIR/yay..."

    # Clone yay repository (as current user, no sudo)
    if git clone --depth 1 https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR/yay"; then
        pushd "$YAY_BUILD_DIR/yay" > /dev/null # Change dir, remember old one
        log "Building and installing yay (this may ask for sudo password for final installation)..."
        # makepkg must be run as a non-root user.
        # -s: sync dependencies (may use sudo)
        # -i: install package after build (will use sudo)
        # --noconfirm: for makepkg itself and for pacman operations it triggers
        if makepkg -si --noconfirm; then
            log "yay installed successfully."
        else
            log "ERROR: Failed to build or install yay with makepkg. Check output above."
            popd > /dev/null # Return to original script directory
            rm -rf "$YAY_BUILD_DIR"
            exit 1
        fi
        popd > /dev/null # Return to original script directory
    else
        log "ERROR: Failed to clone yay repository."
        rm -rf "$YAY_BUILD_DIR" # Clean up if clone failed
        exit 1
    fi
    # Clean up the temporary build directory
    log "Cleaning up yay build directory: $YAY_BUILD_DIR"
    rm -rf "$YAY_BUILD_DIR"
else
    log "AUR helper (yay) is already installed."
fi

# Verify yay installation again
if ! command_exists yay; then
    log "ERROR: yay installation seems to have failed, 'yay' command still not found."
    exit 1
fi

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
    if sudo pacman -S --needed --noconfirm ${pacman_pkg_list}; then
        log "Official package installation command finished successfully."
    else
        log "WARNING: Pacman command finished with errors. Some official packages might not have been found or installed."
        log "Check the pacman output above."
        # Decide whether to exit: # exit 1
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
         # Only add if not already seen AND not a known non-AUR package (like nvm) or the AUR helper itself
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
    # !!! CRITICAL: NO SUDO HERE for yay itself !!!
    # yay will call sudo internally when needed for build dependencies or package installation.
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
# Check if rustup is already installed to avoid re-running its interactive setup if possible
if ! command_exists rustup; then
    sudo pacman -S --needed --noconfirm rustup
    rustup default stable # This might require user interaction if run for the first time
                          # Consider rustup set default-host and rustup toolchain install stable if non-interactive needed
else
    log "Rustup already installed. Ensuring 'stable' toolchain is default."
    rustup default stable
fi


# --- Install nvm (Node Version Manager) ---
if ! command_exists nvm; then
    log "Installing nvm (Node Version Manager)..."
    NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
    # Run the nvm install script as the current user
    curl -o- "$NVM_INSTALL_URL" | bash
    log "nvm installation script executed."
    log "IMPORTANT: You NEED TO RESTART your shell or source your shell's rc file"
    log "           (e.g., ~/.bashrc, ~/.zshrc) for the 'nvm' command to become available."
    log "           The fish nvm plugin will handle loading it within Fish later."
    # Source nvm for the current script session if possible (for bash/zsh)
    # This won't affect the parent shell that launched the script.
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
else
     log "nvm appears to be installed or sourced already."
fi


# --- Configure Fish Shell ---
log "-----------------------------------------------------"
log "Configuring Fish Shell..."
log "-----------------------------------------------------"

if command_exists fish; then
    log "Fish shell is installed. Proceeding with Fisher setup."

    log "Installing Fisher plugin manager and plugins (z, nvm.fish)..."
    # Run fisher commands as the user who will use fish, not as root.
    # If script is run as root, this will install for root's fish config.
    # The earlier EUID check tries to prevent running script as root.
    # Using fish -c 'commands' ensures it runs in a fish environment.
    # The original user may not be the one running `sudo ./script.sh`
    # Best to run the entire script as the intended user.

    # Create fish config directory if it doesn't exist for the user
    FISH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"
    mkdir -p "$FISH_CONFIG_DIR" # fish itself usually creates this, but good to ensure

    # Using sudo -u to run as the original user if sudo was used, otherwise run as current user
    # This is tricky. If 'sudo ./script.sh', $USER is still original user, but EUID is 0.
    # If 'sudo su -' then './script.sh', $USER is root.
    # For simplicity, assuming the script is run by the target user (possibly with sudo for pacman parts)

    if [[ $EUID -eq 0 && -n "$SUDO_USER" ]]; then
        log "Attempting to run Fisher setup as user: $SUDO_USER"
        # Note: `source` within `sudo -u $SUDO_USER fish -c "..."` behaves differently.
        # It's safer to install fisher first, then plugins.
        sudo -u "$SUDO_USER" fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
        sudo -u "$SUDO_USER" fish -c 'fisher install jethrokuan/z'
        sudo -u "$SUDO_USER" fish -c 'fisher install jorgebucaran/nvm.fish'
        log "Fisher and plugins (z, nvm.fish) installation commands executed for user $SUDO_USER."
    elif [[ $EUID -ne 0 ]]; then
        fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
        fish -c 'fisher install jethrokuan/z'
        fish -c 'fisher install jorgebucaran/nvm.fish'
        log "Fisher and plugins (z, nvm.fish) installation commands executed for current user."
    else
        log "WARNING: Running as root without SUDO_USER. Fisher setup will be for root's fish shell."
        fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
        fish -c 'fisher install jethrokuan/z'
        fish -c 'fisher install jorgebucaran/nvm.fish'
    fi
    log "You may need to restart Fish shell for all changes to take effect."

    log "-----------------------------------------------------"
    log "IMPORTANT: To set Fish as your default shell, run the following command"
    log "           manually after this script finishes and enter your password:"
    log ""
    log "  chsh -s $(which fish) $(whoami)" # Use $(which fish) and $(whoami) for robustness
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

# CONFIG_DEST is $HOME/.config, so this should be correct for the user running the script
# If script is 'sudo ./script.sh', $HOME might be root's home unless SUDO_USER is handled.
# For simplicity, we'll assume $HOME is the target user's home.
# If SUDO_USER is set, means script was invoked with `sudo` by a regular user.
TARGET_HOME="$HOME"
if [[ $EUID -eq 0 && -n "$SUDO_USER" ]]; then
    TARGET_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    log "Configurations will be copied to $SUDO_USER's home: $TARGET_HOME"
fi
CONFIG_DEST="$TARGET_HOME/.config"

# Using SCRIPT_CWD for the source directory where the script was executed
log "Checking for configuration directories (like 'hypr/hypr', 'nvim/nvim') in: $SCRIPT_CWD"
log "Target destination: $CONFIG_DEST"

# Ensure the target ~/.config directory exists
if [ ! -d "$CONFIG_DEST" ]; then
    log "Creating destination directory: $CONFIG_DEST"
    mkdir -p "$CONFIG_DEST"
    if [[ $EUID -eq 0 && -n "$SUDO_USER" ]]; then
        chown "$SUDO_USER":"$(id -g "$SUDO_USER")" "$CONFIG_DEST"
    fi
fi

shopt -s nullglob # Prevent loop from running if no matches are found
shopt -s dotglob # Ensure dotfiles (like .config) inside source dirs are copied

# Iterate through items in the script's execution directory
for top_level_item in "$SCRIPT_CWD"/*; do
    if [ -d "$top_level_item" ]; then
        top_level_name=$(basename "$top_level_item")
        inner_config_dir="$top_level_item/$top_level_name"

        if [ -d "$inner_config_dir" ]; then
            target_dir="$CONFIG_DEST/$top_level_name"
            log "Found config structure: '$top_level_name/$top_level_name'. Copying contents to '$target_dir/'"
            mkdir -p "$target_dir"
            if [[ $EUID -eq 0 && -n "$SUDO_USER" ]]; then
                chown "$SUDO_USER":"$(id -g "$SUDO_USER")" "$target_dir"
            fi

            if cp -ar "$inner_config_dir/." "$target_dir/"; then
                log " -> Successfully copied contents of '$inner_config_dir' to '$target_dir/'"
                if [[ $EUID -eq 0 && -n "$SUDO_USER" ]]; then
                    # Ensure correct ownership of copied files
                    chown -R "$SUDO_USER":"$(id -g "$SUDO_USER")" "$target_dir"
                fi
            else
                log "ERROR: Failed to copy contents from '$inner_config_dir' to '$target_dir/'."
            fi

            if [[ "$top_level_name" == "backgrounds" ]]; then
                 log "NOTE: Copied 'backgrounds/backgrounds/*' to '$CONFIG_DEST/backgrounds/'. You might want to move these images elsewhere (e.g., $TARGET_HOME/Pictures/Wallpapers)."
            fi
        # else
            # log "Skipping '$top_level_name': No inner directory named '$top_level_name' found inside."
        fi
    fi
done

log "Copying starship.toml config file..."
if [ -f "$SCRIPT_CWD/starship.toml" ]; then
    cp "$SCRIPT_CWD/starship.toml" "$CONFIG_DEST/starship.toml"
    if [[ $EUID -eq 0 && -n "$SUDO_USER" ]]; then
        chown "$SUDO_USER":"$(id -g "$SUDO_USER")" "$CONFIG_DEST/starship.toml"
    fi
    log " -> Successfully copied starship.toml to $CONFIG_DEST/starship.toml"
else
    log "WARNING: starship.toml not found in $SCRIPT_CWD. Skipping."
fi


shopt -u nullglob dotglob

log "Finished copying configuration files/folders."

# --- Finished ---
log "-----------------------------------------------------"
log " Installation and Setup Script Finished!"
log "-----------------------------------------------------"
log ""
log "Post-operation Notes:"
log " *  Configuration Files: Copied contents from '$SCRIPT_CWD/dirname/dirname/' to '$CONFIG_DEST/dirname/' for relevant directories."
log " *  Backgrounds: Image files from '$SCRIPT_CWD/backgrounds/backgrounds/' were copied to '$CONFIG_DEST/backgrounds/'. Consider moving them."
log " *  Fish Shell & Fisher:"
log "    - Fisher plugin manager and plugins (z, nvm.fish) were installed for user: ${SUDO_USER:-$USER}."
log "    - TO MAKE FISH YOUR DEFAULT SHELL: Run 'chsh -s $(which fish) ${SUDO_USER:-$USER}' manually."
log "    - Log out and log back in for the default shell change to apply."
log "    - You might need to start a new Fish shell instance for plugin functions to be fully available."
log " *  NVM: Remember to RESTART YOUR SHELL (or source rc files for Bash/Zsh). For Fish, the nvm.fish plugin should handle loading NVM automatically in new Fish sessions."
log "    - After restarting/sourcing, install Node.js with 'nvm install node'."
log " *  Fcitx5: Enable by setting environment variables (export GTK_IM_MODULE=fcitx, etc.) and potentially starting the 'fcitx5' daemon. Log out/in may be required."
log " *  Starship: If fish is your shell, add 'starship init fish | source' to your $TARGET_HOME/.config/fish/config.fish and restart the shell."
log " *  PipeWire: Ensure services are running ('systemctl --user status pipewire pipewire-pulse wireplumber')."
log " *  Review Logs: Check the script output above for any errors."
log ""
log "Enjoy your new setup!"

exit 0
