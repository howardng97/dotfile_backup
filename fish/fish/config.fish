# ~/.config/fish/config.fish

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
set -x INPUT_METHOD fcitx

# Thiết lập PATH
set -x PATH $PATH $HOME/go/bin
set -x PATH $HOME/.local/bin $PATH
set -x PATH $HOME/flutter/bin $PATH

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


