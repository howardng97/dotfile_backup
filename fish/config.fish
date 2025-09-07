# ~/.config/fish/config.fish
set -U fish_greeting
# Khởi tạo Starship prompt
starship init fish | source
bass source /usr/share/nvm/init-nvm.sh
# Thiết lập alias
alias ls "ls --color=auto"
alias grep "grep --color=auto"

# Biến môi trường
set -x GTK_IM_MODULE fcitx
set -x QT_IM_MODULE fcitx
set -x XMODIFIERS "@im=fcitx"

# Thiết lập PATH
set -x PATH $PATH $HOME/go/bin
set -x PATH $HOME/.local/bin $PATH

set -x PATH $HOME/flutter/bin $PATH

set -x __GLX_VENDOR_LIBRARY_NAME nvidia
set -x LIBVA_DRIVER_NAME nvidia
set -x GBM_BACKEND nvidia-drm

#set -x XDG_CURRENT_DESKTOP Hyprland
set -x XDG_SESSION_TYPE wayland
# android dev PATH
# Nạp Cargo
set -x PATH $HOME/.cargo/bin $PATH
# Thiết lập Bun
set -x BUN_INSTALL "$HOME/.bun"
set -x PATH "$BUN_INSTALL/bin" $PATH
# Thiết lập trình soạn thảo mặc định
set -x EDITOR nvim

 #NVM
set -gx NVM_DIR $HOME/.nvm
set -gx PATH $NVM_DIR/bin $PATH


# android home
set -x ANDROID_HOME /opt/android-sdk
set -x PATH $PATH $ANDROID_HOME/emulator
set -x PATH $PATH $ANDROID_HOME/platform-tools
set -x PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin

# opencode
fish_add_path /home/howard/.opencode/bin
