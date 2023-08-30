#!/bin/sh

read -p "Would you like to create a new SSH key? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  ssh-keygen -t rsa
  
  echo "Please add this public key to Github \n"
  echo "https://github.com/account/ssh \n"
  read -p "Press [Enter] key after this..."
fi

echo "Installing Homebrew"
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update

echo "Install XCode CLI Tool"
xcode-select --install

echo "Installing Oh My Zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone git://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
echo "source ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
sed -io 's/^plugins=.*/plugins=(autojump git brew common-aliases zsh-autosuggestions copydir copyfile encode64 node osx sublime tmux xcode pod docker git-extras git-prompt)/' ~/.zshrc
sed -io 's/^ZSH_THEME.*/ZSH_THEME="dpoggi"/' ~/.zshrc

# echo "Install VIM settings"
# git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime

echo "Install Homebrew Packages from BrewFile, this might take a while"
brew tap homebrew/bundle
brew bundle
echo "Cleaning up brew"
brew cask cleanup
brew cleanup

echo "Configrating Git"
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

# echo "Copying dotfiles from Github"
# cd ~
# git clone git@github.com:bradp/dotfiles.git .dotfiles
# cd .dotfiles
# sh symdotfiles

# echo "Enabling Services"
# open /Applications/Alfred\ 4.app
# open /Applications/Gas\ Mask.app
# open /Applications/Clipy.app
# open /Applications/Rectangle.app
