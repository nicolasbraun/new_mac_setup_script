# Basic Setup
```
git clone https://bitbucket.org/snippets/edlabtc/4Lkd9/mac-setup.git
cd mac-setup && sh ./install.sh
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