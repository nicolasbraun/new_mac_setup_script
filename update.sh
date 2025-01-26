#!/bin/sh 
git pull --recursive


echo "Updating Homebrew"
brew update && brew upgrade && brew cleanup; 
brew bundle --file=Brewfile
brew doctor