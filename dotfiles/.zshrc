#	                ██
#	               ░██
#	 ██████  ██████░██      ██████  █████
#	░░░░██  ██░░░░ ░██████ ░░██░░█ ██░░░██
#	   ██  ░░█████ ░██░░░██ ░██ ░ ░██  ░░
#	  ██    ░░░░░██░██  ░██ ░██   ░██   ██
#	 ██████ ██████ ░██  ░██░███   ░░█████
#	░░░░░░ ░░░░░░  ░░   ░░ ░░░     ░░░░░

COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_UPDATE=true
HYPHEN_INSENSITIVE=true

unsetopt nomatch
unsetopt flowcontrol

setopt APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt INTERACTIVE_COMMENTS

typeset -A ZSH_HIGHLIGHT_PATTERNS
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red' 'trash' 'underline,fg=red')

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:git-checkout:*' sort false

DOTFILES_PATH=$HOME/new_mac_setup
ZSH_CUSTOM=$DOTFILES_PATH/zsh-custom
ZSH_THEME="dpoggi"

plugins=(
    aliases
    aws
    brew
    common-aliases
    copyfile
    docker
    dotenv
    encode64
    flutter
    forgit
#    fzf
    git
    git-extras
    git-prompt
    gradle
    node
    pyenv
    qrcode
    nvm
    ruby
    rvm
    terraform
    xcode
    zsh-syntax-highlighting
    z
)

source $DOTFILES_PATH/.oh-my-zsh/oh-my-zsh.sh
source $ZSH_CUSTOM/zshrc-loaded


PATH="/bin"
path+=($DOTFILES_PATH/bin)
path+=($DOTFILES_PATH/bin/misc)
path+=($DOTFILES_PATH/bin/git)
path+=(/usr/local/bin)
path+=(/usr/local/opt)
path+=(/usr/local/share/npm/bin)
path+=(/usr/local/git/bin)
path+=(/usr/local/bin)
path+=(/usr/bin)
path+=(/bin)
path+=(/usr/local/sbin)
path+=(/usr/sbin)
path+=(/sbin)
path+=($ANDROID_HOME/emulator)
path+=($ANDROID_HOME/platform-tools)
path+=($HOME/Development/flutter/bin)
path+=($HOME/.pub-cache/bin)
path+=($PYENV_ROOT/bin)
export PATH
