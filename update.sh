#!/bin/sh 
git pull


echo "Updating Homebrew"
brew update && brew upgrade && brew cleanup && brew cask cleanup; brew bundle; brew doctor

echo "Updating Oh My Zsh"
env ZSH=$ZSH sh $ZSH/tools/upgrade.sh

echo "Updating VIM"
cd ~/.vim_runtime
git pull --rebase

echo "Updating Tmux"
cd ~/.tmux
git pull --rebase