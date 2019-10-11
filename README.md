# Basic Setup
```
git clone https://gist.github.com/059e210f8fe15e7eadc4a28e8b3e6b27.git setup
cd setup && sh ./init.sh
```
# Shell Configuration

1. Enable plugins - edit ***~/.zshrc***

    Update plugins

    ```
     plugins=(autojump git brew common-aliases zsh-autosuggestions copydir copyfile encode64 node osx sublime tmux xcode pod docker git-extras git-prompt)
    ```

# Generate Your Development SSH Key
1. Generate your key for the development machine

    ```
    ssh-keygen -t rsa -b 2048
    ```

1. Copy your public key (***~/.ssh/id_rsa.pub***) to your Bitbucket Account's "SSH Keys"