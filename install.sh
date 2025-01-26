#!/usr/bin/env bash

#
#  ██                    ██              ██  ██
#  ░░                    ░██             ░██ ░██
#   ██ ███████   ██████ ██████  ██████   ░██ ░██
#  ░██░░██░░░██ ██░░░░ ░░░██░  ░░░░░░██  ░██ ░██
#  ░██ ░██  ░██░░█████   ░██    ███████  ░██ ░██
#  ░██ ░██  ░██ ░░░░░██  ░██   ██░░░░██  ░██ ░██
#  ░██ ███  ░██ ██████   ░░██ ░░████████ ███ ███
#  ░░ ░░░   ░░ ░░░░░░     ░░   ░░░░░░░░ ░░░ ░░░
#

set -Eeuo pipefail

# Set up colors.
_colors_bold=$(tput bold)
_colors_red=$(tput setaf 1)
_colors_green=$(tput setaf 2)
_colors_cyan=$(tput setaf 6)
_colors_reset=$(tput sgr0)

# Get the dotfiles dir in case it's named something else.
_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_dotfiles_dir="${_script_dir}/dotfiles"

# Confirm the path.
echo ""
echo -e "The dotfiles folder is set as ${_colors_bold}${_colors_cyan}${_dotfiles_dir}${_colors_reset}. Is this correct?"
read -r -p "(press enter to confirm or type in a new path)  " confirm

# If a new path is passed in, confirm it.
if [ -n "$confirm" ]; then
	if [[ ! -d "$confirm" ]]; then
		echo -e "${_colors_red}Could not find ${_colors_bold}${confirm}${_colors_reset}, please re-run the script.${_colors_reset}"
		exit 1
	fi

	# set to the new dir.
	_dotfiles_dir="$confirm"

	# Confirm the new path.
	echo -e "The dotfiles folder is now set as ${_colors_bold}${_colors_cyan}${_dotfiles_dir}${_colors_reset}. Is this correct?"
	read -r -p "(press enter to confirm)  " confirm

	if [ -n "$confirm" ]; then
		echo -e "${_colors_red}Quitting, please re-run the script.${_colors_reset}"
		exit 1
	fi
fi

echo ""
echo -e "${_colors_green}Setting up dotfiles in ${_colors_bold}${_dotfiles_dir}${_colors_reset}..."
echo ""

_files_to_symlink="
.curlrc
.gitconfig
.gitignore
.gvimrc
.npmrc
.vim
.vimrc
.zprofile
.zshrc
"

mkdir -p "$HOME/.config"

# Symlink them up
for f in $_files_to_symlink; do
	echo "${_colors_cyan}${_dotfiles_dir}/${f}${_colors_reset} ${_colors_bold}→${_colors_reset} ${_colors_cyan}$HOME/${f}${_colors_reset}"

	if [[ -L "$HOME/$f" ]]; then
		# If it's already a symlink, skip it.
		echo "${_dotfiles_dir}/$f is already symlinked, skipping..."
	elif [[ ! -f "${_dotfiles_dir}/$f" && ! -d "${_dotfiles_dir}/$f" ]]; then
		# Make sure the target file exists in the dotfiles before symlinking.
		echo "Could not find ${_dotfiles_dir}/$f, skipping..."
	else
		# If the file already exists, back it up first.
		if [[ -f "$HOME/$f" || -d "$HOME/$f" ]]; then
			echo "$HOME/$f already exists, backing it up..."
			mv "$HOME/$f" "$HOME/$f.bak"
		fi

		ln -nfsv "${_dotfiles_dir}/$f" "$HOME/$f" 1>/dev/null
	fi
done

echo ""
echo "${_colors_green}Dotfiles symlinked.${_colors_reset}"
echo ""

if [[ $_dotfiles_dir != "$HOME/dotfiles" ]]; then
	echo "${_colors_red}HEY YOU GOTTA DO THIS TO NOT BREAK STUFF!${_colors_reset}"
	echo ""
	echo "You need to modify ${_colors_cyan}.zshrc${_colors_reset} to point to the correct folder."
	echo ""
	echo "Replace ${_colors_bold}${_colors_cyan}export DOTFILES_PATH=\"\$HOME/dotfiles${_colors_reset}\" with: ${_colors_bold}${_colors_cyan}export DOTFILES_PATH=\"${_dotfiles_dir}\""
	echo ""
fi

# Mac settings
./install_mac_settings.sh

# SSH
read -p "Would you like to create a new SSH key? [y/n]" -n 1 -r
echo # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
	ssh-keygen -t rsa

	echo "SSH key copied to clipboard"
	echo "Please add this public key to Github \n"
	echo "https://github.com/account/ssh \n"
	cat ~/.ssh/cat id_rsa.pub | pbcopy
	read -p "Press [Enter] key after this..."
fi
# Avoid permanent prompt for passphrase
echo "Host *
  UseKeychain yes" >>~/.ssh/config

# BREW
echo "Installing Homebrew"
if test ! $(which brew); then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Already installed"
fi
source ~/.zshrc
brew update

# # Xcode CLI
echo "Install XCode CLI Tool"
xcode-select --install

# Brew packages

echo "Install Homebrew Packages from BrewFile, this might take a while"
brew tap homebrew/bundle
brew bundle --file=Brewfile
echo "Cleaning up brew"
brew cleanup

sh "./install_manual.sh"

echo "Ready to go, well done"
