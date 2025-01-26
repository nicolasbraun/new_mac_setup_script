#             ██ ██
#            ░██░░
#   ██████   ░██ ██  ██████    ██████  █████   ██████
#  ░░░░░░██  ░██░██ ░░░░░░██  ██░░░░  ██░░░██ ██░░░░
#   ███████  ░██░██  ███████ ░░█████ ░███████░░█████
#  ██░░░░██  ░██░██ ██░░░░██  ░░░░░██░██░░░░  ░░░░░██
# ░░████████ ███░██░░████████ ██████ ░░██████ ██████
#  ░░░░░░░░ ░░░ ░░  ░░░░░░░░ ░░░░░░   ░░░░░░ ░░░░░░
#

#########################################
# Paths                                 #
#########################################
alias desk="cd ${HOME}/Desktop"

#########################################
# Replace commands                      #
#########################################
alias c="pbcopy"
alias p="pbpaste"

#########################################
# Git                                   #
#########################################
alias g="git"
alias gs="git status"
alias gc="git commit -m"
alias gcb="git fetch && git checkout -b $@ origin/$@"
alias gpre="git pull --rebase origin $1"
alias gcm="git commit -m $@"

alias forgit_checkout_branch="gco"

#########################################
# Un-git git commands                   #
#########################################
alias current-branch="git current-branch"

#########################################
# Editing 							    #
#########################################
alias ssource="source ${DOTFILES_PATH}/.zshrc"

#########################################
# Annoyances							#
#########################################
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias xcode-agree="sudo xcodebuild -license accept"

#########################################
# Hide / Show files                     #
#########################################
alias unhidelibrary="chflags nohidden ~/Library"

alias hide="chflags hidden $0"
alias unhide="chflags nohidden $0"

#########################################
# youtube-dl                             #
#########################################
alias dyt="ytdl '${HOME}/Desktop'"
