#!/usr/bin/env bash

DOTFILES_ROOT=$HOME/dotfiles
DOTFILES_REPO=https://github.com/KarimAziev/dotfiles
EMACS_DIRECTORY="$HOME/emacs"

read -rp "Update git (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        sudo add-apt-repository ppa:git-core/ppa
        sudo apt update
        sudo apt-get install -y git
        git config --global init.defaultBranch main
        ;;
    * )
        echo "Skipping git"
        ;;
esac


if [ -d "$DOTFILES_ROOT" ];
then
    cd "$DOTFILES_ROOT"
    git pull origin main
else
    git clone $DOTFILES_REPO "$DOTFILES_ROOT"
    cd "$DOTFILES_ROOT"
fi

cd "$DOTFILES_ROOT" || exit

source ./installed.sh
source ./apt-init.sh
source ./build-emacs.sh


compile-emacs() {
    read -rp "Configure emacs (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            install-emacs-deps
            compile-emacs
            build-emacs
            ;;
        * )
            echo "Emacs is no configured"
            ;;
    esac

    case ${answer:0:1} in
        y|Y )
            install-emacs
            ;;
        * )
            echo "Emacs is not installed"
            ;;
    esac
}

cd "$HOME"

compile-emacs

cd "$HOME"

if ! (installed flacon); then
    sudo apt-get update && sudo apt-get install -y flacon
fi
if ! (installed silversearcher-ag); then
    sudo apt-get install -y silversearcher-ag
fi

if ! (installed dconf-editor); then
    sudo apt-get -y install dconf-editor
fi

if ! (installed avidemux-cli); then
    sudo apt install software-properties-common apt-transport-https -y
    sudo add-apt-repository ppa:xtradeb/apps -y
    sudo apt install avidemux* -y
fi

# pass and extensions
if ! (installed pass); then
    sudo apt-get install -y pass
fi

if ! (installed pass-extension-import); then
    sudo apt install software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt install python3.9
    sudo apt install python3-setuptools python3-yaml
    wget -qO - https://pkg.pujol.io/debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/pujol.io.gpg >/dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/pujol.io.gpg] https://pkg.pujol.io/debian/repo all main' | sudo tee /etc/apt/sources.list.d/pkg.pujol.io.list
    sudo apt-get update
    sudo apt-get install pass-extension-import
fi


# gh
if ! (installed gh); then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh
fi

read -rp "Install deps for mu4e (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        sudo apt install meson gir1.2-glib-2.0
        sudo apt-get install gmime-3.0 libxapian-dev libxapian30 guile-3.0 xapian-omega xapian-tools
        ;;
    * )
        echo "Dependencies for mu4e is not installed"
        ;;
esac


# keyboard setup

read -rp "Set emacs key theme (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
        ;;
    * )
        echo "Emacs key theme is not setted"
        ;;
esac


read -rp "Remap capslock to ctrl (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        source ./remap-caps.sh
        ;;
    * )
        echo "Not remapping"
        ;;
esac

# google chrome
read -rp "Install google chrome (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i google-chrome-stable_current_amd64.deb
        ;;
    * )
        echo "google chrome is not installed"
        ;;
esac

read -rp "Install chrome session dump (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        sudo curl -o /usr/bin/chrome-session-dump -L 'https://github.com/lemnos/chrome-session-dump/releases/download/v0.0.2/chrome-session-dump-linux' && sudo chmod 755 /usr/bin/chrome-session-dump
        ;;
    * )
        echo "chrome session is not installed"
        ;;
esac

# Nvm, node, npm, yarn etc

read -rp "Install nvm (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        source ./install-nvm.sh
        ;;
    * )
        echo "Not installing NVM"
        ;;
esac
