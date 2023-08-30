#!/bin/sh

read -p "Would you like to create a new SSH key? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  ssh-keygen -t rsa
  
  echo "Please add this public key to Github \n"
  echo "https://github.com/account/ssh \n"
  echo "Use this command to copy cat ~/.ssh/cat id_rsa.pub | pbcopy"
  read -p "Press [Enter] key after this..."
fi

echo "Installing Homebrew"
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
export PATH=/opt/homebrew/bin:$PATH
source ~/.zshrc
brew update

echo "Install XCode CLI Tool"
xcode-select --install

if [ -z "${ZSH_VERSION+xxx}" ]
  echo "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
git clone git@github.com:zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone git@github.com:zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
echo "source ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
sed -io 's/^plugins=.*/plugins=(autojump git brew common-aliases zsh-autosuggestions copydir copyfile encode64 node osx nvm xcode pod docker git-extras git-prompt)/' ~/.zshrc
sed -io 's/^ZSH_THEME.*/ZSH_THEME="dpoggi"/' ~/.zshrc


echo "Install Homebrew Packages from BrewFile, this might take a while"
brew tap homebrew/bundle
brew bundle --file=Brewfile_basics

read -p "Would you like to install personal apps? (Spotify, VLC...) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY_PERSONAL =~ ^[Yy]$ ]]
then
  brew bundle --file=Brewfile_personal
fi

read -p "Would you like to install Works apps? (Dev stuff mostly) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY_WORK =~ ^[Yy]$ ]]
then
  brew bundle --file=Brewfile_work
  # NVM & Node
  PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash'
  nvm install node
fi

read -p "Would you like to install Gaming apps? (Bnet steam) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY_GAMING =~ ^[Yy]$ ]]
then
  brew bundle --file=Brewfile_gaming
fi

echo "Cleaning up brew"
brew cask cleanup
brew cleanup

echo "Configurating Git"
git config --global user.name "Nicolas Braun"
git config --global user.email "braunico@gmail.com"
git config --global merge.tool diffmerge
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global core.editor $(which code)
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
git config --global alias.tree "log --graph --full-history --all --color --date=short --pretty=format:'%Cred%x09%h %Creset%ad%Cblue%d %Creset %s %C(bold)(%an)%Creset'"

echo "Done"
echo "Remember to delete cask using cask zap"
echo "
# TODO
# echo "Copying dotfiles from Github"
# cd ~
# git clone git@github.com:bradp/dotfiles.git .dotfiles
# cd .dotfiles
# sh symdotfiles
