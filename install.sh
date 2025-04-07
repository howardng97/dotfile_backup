#!/usr/bin/env bash

# Stop on error
set -e

# --- Configuration ---

# Packages from official repositories
PACMAN_PACKAGES=(
    blueman
    btop
    fish
    fcitx5
    fcitx5-configtool # GUI configuration tool for fcitx5
    fcitx5-gtk        # GTK input module
    fcitx5-qt         # Qt input module
    fcitx5-bamboo     # Vietnamese input method engine for fcitx5
    fzf
    git
    hyprland
    hyprlock
    hyprpaper
    kitty
    lazydocker
    lazygit
    neovim
    nwg-look          # GTK settings editor, replacement for lxappearance
    pavucontrol       # PulseAudio volume control (works with PipeWire-Pulse)
    pipewire-alsa     # ALSA configuration client/plugin for PipeWire
    pipewire-jack     # JACK implementation for PipeWire
    starship          # Cross-shell prompt
    ttf-cascadia-code-nerd # Nerd Font version of Cascadia Code
    tree
    vlc
    waybar            # Wayland bar for Sway/Hyprland
    wl-clipboard      # Wayland clipboard utilities
    wlsunset          # Day/night gamma adjustments for Wayland
    wofi              # Launcher/menu for Wayland
    yazi              # Terminal file manager
    zip               # Zip utility
    zoxide            # Smarter cd command
    ripgrep
    # Add base-devel and git if not already assumed to be present
    base-devel
    git
    curl              # Needed for nvm install script
    wget              # Alternative for nvm install script / other downloads
)

# Packages from the AUR (Arch User Repository)
AUR_PACKAGES=(
    catppuccin-gtk-theme-mocha # Catppuccin GTK Theme
    google-chrome              # Web browser
    nerdfetch                  # System information fetch tool
    termius-bin                # Termius SSH client (binary version)
)

# --- Functions ---

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


# --- Ensure Rust is up ---
log "Install rust and rust deps"
sudo pacman -S rustup
rustup default stable

# --- Install yay (AUR Helper) ---
if ! command_exists yay; then
    log "yay not found. Installing yay..."
    if [[ -d "/tmp/yay-git" ]]; then
        log "Removing existing /tmp/yay-git directory..."
        rm -rf /tmp/yay-git
    fi
    git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
    (
        cd /tmp/yay-git || exit 1
        # Build and install, using sudo only for the final installation step
        makepkg -si --noconfirm
    )
    # Clean up
    rm -rf /tmp/yay-git
    log "yay installation complete."
else
    log "yay is already installed."
fi

# --- Install Official Packages ---
log "Installing packages from official repositories..."
# Convert array to space-separated string
pacman_pkg_list="${PACMAN_PACKAGES[*]}"
sudo pacman -S --needed --noconfirm $pacman_pkg_list
log "Official package installation complete."

# --- Install AUR Packages ---
if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
    log "Installing packages from the AUR..."
    # Convert array to space-separated string
    aur_pkg_list="${AUR_PACKAGES[*]}"
    yay -S --needed --noconfirm $aur_pkg_list
    log "AUR package installation complete."
else
    log "No AUR packages specified."
fi

# --- Install nvm (Node Version Manager) ---
log "Installing nvm (Node Version Manager)..."
# Fetch the latest install script URL (this is generally stable but could change)
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
curl -o- "$NVM_INSTALL_URL" | bash
log "Set default shell to fish"
chsh -s /usr/bin/fish
fish
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install jethrokuan/z
fisher install jorgebucaran/nvm.fish


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
log " Installation Script Finished!"
log "-----------------------------------------------------"
log ""
log "Post-installation Notes:"
log " *  NVM: Remember to configure nvm in your shell's rc file (e.g., .bashrc, .zshrc) as mentioned above and then run 'nvm install node'."
log " *  Fcitx5: To enable Fcitx5 input methods, you usually need to set environment variables. Add these to your shell profile (like ~/.profile or ~/.pam_environment) or DE's startup configuration:"
log "      export GTK_IM_MODULE=fcitx"
log "      export QT_IM_MODULE=fcitx"
log "      export XMODIFIERS=@im=fcitx"
log "    You might need to log out and back in for these changes to take effect. You may also need to start the fcitx5 daemon."
log " *  Starship: To use Starship prompt, add 'eval \"\$(starship init bash)\"' (or zsh/fish equivalent) to your .bashrc/.zshrc/.config/fish/config.fish."
log " *  Hyprland/Waybar/Wofi/etc.: These require configuration files. Check their respective documentation or look for dotfile examples online."
log " *  Catppuccin Theme: Use 'nwg-look' or another GTK theme switcher to apply the Catppuccin theme."
log " *  PipeWire: Ensure PipeWire services are running (usually handled by systemd user units). Check 'systemctl --user status pipewire pipewire-pulse wireplumber'."
log ""
log "Enjoy your new setup!"

exit 0
