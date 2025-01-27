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


###########################################
#                                         #
#          Homebrew and apps		  #
#                                         #
###########################################


echo "${_colors_bold}Installing Homebrew...${_colors_reset}"
if test ! $(which brew); then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
 	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	echo "Already installed"
fi

# Brew packages

echo "Install Homebrew Packages from BrewFile, this might take a while"
brew tap homebrew/bundle
brew bundle --file=Brewfile || echo "${_colors_red}Could not install all brew packages. Check and relaunch${_colors_reset}"
echo "Cleaning up brew"
sudo xcodebuild -license accept
brew cleanup

###########################################
#                                         #
#               Dotfiles                  #
#                                         #
###########################################
echo "${_colors_bold}Symlinking the dotfiles...${_colors_reset}"

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

if [[ $_dotfiles_dir != "$HOME/new_mac_setup/dotfiles" ]]; then
	echo "${_colors_red}HEY YOU GOTTA DO THIS TO NOT BREAK STUFF!${_colors_reset}"
	echo ""
	echo "You need to modify ${_colors_cyan}.zshrc${_colors_reset} to point to the correct folder."
	echo ""
	echo "Replace ${_colors_bold}${_colors_cyan}export DOTFILES_PATH=\"\$HOME/new_mac_setup/dotfiles${_colors_reset}\" with: ${_colors_bold}${_colors_cyan}export DOTFILES_PATH=\"${_dotfiles_dir}\""
	echo ""
fi

###########################################
#                                         #
#               SSH                       #
#                                         #
###########################################

echo "${_colors_bold}Creating an SSH Key...${_colors_reset}"
read -p "Would you like to create a new SSH key? [y/n]" -n 1 -r
echo # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
	ssh-keygen -t rsa
 	echo "SSH key created."
	cat ~/.ssh/id_rsa.pub | pbcopy
 	echo -e "${_colors_bold}${_colors_cyan}Please add this public key to Github${_colors_reset}"
	echo -e "https://github.com/account/ssh"
	read -p "Press [Enter] key to continue"
 else
  echo "SSH key generation skipped."
  echo ""
fi
# Avoid permanent prompt for passphrase
echo -e "Setting SSH config to avoid permanent prompt for passphrase"
mkdir -p ~/.ssh

# Check if the line already exists in ~/.ssh/config
if ! grep -q "^UseKeychain yes" ~/.ssh/config 2>/dev/null; then
  echo "Adding configuration to ~/.ssh/config..."
  # Append the configuration to the file
  {
    echo "Host *"
    echo "  UseKeychain yes"
  } >> ~/.ssh/config
  echo "Configuration added to ~/.ssh/config."
else
  echo "Configuration already exists in ~/.ssh/config. No changes made."
fi

###########################################
#                                         #
#            MAC OS SETTINGS              #
#                                         #
###########################################

echo "${_colors_bold}Setting up MACOS Settings.${_colors_reset}"

#Mostly yaken from https://github.com/mathiasbynens/dotfiles/blob/master/.macos
echo "${_colors_bold}Setting some MacOS settings...${_colors_reset}"

#"Disabling system-wide resume"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

#"Disable 'natural' (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

#"Disabling automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
# sudo spctl --master-disable # Causes error in Mac OS Sequoia
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#"Saving to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

#"Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

#"Disable smart quotes and smart dashes as they are annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

#"Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#"Disabling press-and-hold for keys in favor of a key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

#"Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 1.5
defaults write -g com.apple.mouse.scaling 1.5

#"Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

#"Finder: Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Finder: Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Finder: Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Finder: Show hidden files"
defaults write com.apple.Finder AppleShowAllFiles true

#"Use List view in all Finder windows by default"
# Other values are `icnv`, `clmv`, ``glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

#"Finder : Show path bar"
defaults write com.apple.finder ShowPathbar -bool true

#"Finder : Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

#"Finder : Search the current folder by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

#"Finder : Keep folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

#"Finder: Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

#"Finder: Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Disable the warning before emptying the Trash
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36

#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

#"Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

#"Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

#"Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

#"Disable the sudden motion sensor as its not useful for SSDs"
sudo pmset -a sms 0

#"Speeding up wake from sleep to 24 hours from an hour"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay 86400

#"Disable annoying backswipe in Chrome"
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

#"Setting screenshots location to ~/Desktop/Screenshots"
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"

#"Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

#"Use `~/Downloads/Incomplete` to store incomplete downloads"
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

#"Don't prompt for confirmation before downloading"
defaults write org.m0k.transmission DownloadAsk -bool false

#"Trash original torrent files"
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

#"Hide the donate message"
defaults write org.m0k.transmission WarningDonate -bool false

#"Hide the legal disclaimer"
defaults write org.m0k.transmission WarningLegal -bool false

killall Finder

echo ""
read -p "Would you like to remove all Dock persistent icons ? [y/n]"  -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    defaults write com.apple.dock persistent-apps -array
fi
killall Dock
echo "${_colors_bold}Done. You may need to reboot for some to take effect.${_colors_reset}"

###########################################
#                                         #
#            MANUAL STUFF                 #
#                                         #
###########################################

echo "${_colors_bold}There is still some manual stuff to do...${_colors_reset}"
echo ""
echo "${_colors_bold}In MACOS setting${_colors_reset}"
echo "	- Keyboard: Change the shortcut to 'Move focus to next window' Alt+tab is a good one"
echo "	- Keyboard: Disable Spotlight."
echo "  - Password: Set bitwarden as source"
echo "${_colors_bold}Raycast${_colors_reset}"
echo "	- Import your backupfile."
echo "${_colors_bold}Firefox${_colors_reset}"
echo "	- Login"
echo "	- Import Sideberry backup"
echo ""
echo "${_colors_bold}Finder${_colors_reset}"
echo "	- Set the sidebar favorites"
echo "	- Clean dock"
read -p "Would you like to try to automaticaly open those ? [y/n]"  -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "x-apple.systempreferences:com.apple.preference.keyboard" || echo "Failed to open Preferences"
    open "Applications/RayRaycast.app" || echo "Failed to open Raycast.app."
    open "/Applications/Visual\ Studio\ Code.app" || echo "Failed to open VSCode"
    open "/Applications/Firefox.app"|| echo "Failed to open Firefox"
 else
  echo "Skipping opening apps"
  echo ""
fi

echo "${_colors_bold}${_colors_green}All done! Check for errors and reload if needed.${_colors_reset}"
