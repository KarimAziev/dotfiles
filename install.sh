#!/bin/bash

function installed() {
    return $(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')
}

read -p "Update git (y/n)? " answer

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

read -p "Autoremove emacs (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        sudo apt remove --autoremove emacs emacs-common
        ;;
    * )
        echo "Not removing emacs and emacs-common"
        ;;
esac

pkgs=(fd-find pandoc viewnior vlc heif-gdk-pixbuf youtube-dl hunspell w3m mpv cmake libtool libtool-bin
      curl wget net-tools build-essential autoconf make gcc libgnutls28-dev libtiff5-dev
      libgif-dev libjpeg-dev libpng-dev libxpm-dev libncurses-dev texinfo libjansson4 libjansson-dev
      libgccjit0 libgccjit-10-dev gcc-10 g++-10
      libgtk-3-dev libwebkit2gtk-4.0-dev gnutls-bin
      libncurses5-dev libharfbuzz-dev imagemagick libmagickwand-dev xaw3dg-dev libx11-dev)
missing_pkgs=""

for pkg in ${pkgs[@]}; do
    if ! $(installed $pkg) ; then
        missing_pkgs+=" $pkg"
    fi
done



if [ ! -z "$missing_pkgs" ]; then
    echo $missing_pkgs
    sudo apt install -y $missing_pkgs
fi



if [ ! -d $HOME/emacs ];
then
    echo "Cloning emacs"
    git clone --depth 1 https://git.savannah.gnu.org/git/emacs.git $HOME/emacs
    cd $HOME/emacs
fi

cd $HOME/emacs

echo $PWD
echo "PULLING EMACS"

git pull origin $(git rev-parse --abbrev-ref HEAD)

read -p "Configure emacs (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        export CC=/usr/bin/gcc-10 CXX=/usr/bin/gcc-10

        ./autogen.sh

        echo $CC
        echo "Configuring emacs"
        ./configure --with-native-compilation --with-json --with-pgtk --with-xwidgets --with-cairo --with-gif --with-png --with-jpeg \
                    --with-gnutls --with-mailutils --with-threads --with-included-regex --with-harfbuzz --with-tiff --with-xpm \
                    --with-zlib --with-xft --with-xml2
        ;;
    * )
        echo "Finished"
        ;;
esac


read -p "Compile emacs (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        make -j$(nproc)
        sudo make install
        ;;
    * )
        echo "Emacs is not compiled"
        ;;
esac

cd $HOME

if !(installed flacon); then
    sudo add-apt-repository -y ppa:flacon/ppa
    sudo apt-get update && sudo apt-get install -y flacon
fi
if !(installed silversearcher-ag); then
    sudo apt-get install -y silversearcher-ag
fi

if !(installed dconf-editor); then
    sudo apt-get -y install dconf-editor
fi

if !(installed avidemux-cli); then
    sudo apt install software-properties-common apt-transport-https -y
    sudo add-apt-repository ppa:xtradeb/apps -y
    sudo apt install avidemux* -y
fi

# pass and extensions
if !(installed pass); then
    sudo apt-get install -y pass
fi

if !(installed pass-extension-import); then
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
if !(installed gh); then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh
fi

# keyboard setup

read -p "Set emacs key theme (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
        ;;
    * )
        echo "Emacs key theme is not setted"
        ;;
esac


read -p "Remap capslock to ctrl (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        setxkbmap -option 'caps:ctrl_modifier,grp:toggle'
        sudo dpkg-reconfigure keyboard-configuration
        ;;
    * )
        echo "Not remapping"
        ;;
esac

# google chrome
read -p "Install google chrome (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i google-chrome-stable_current_amd64.deb
        ;;
    * )
        echo "google chrome is not installed"
        ;;
esac

sudo curl -o /usr/bin/chrome-session-dump -L 'https://github.com/lemnos/chrome-session-dump/releases/download/v0.0.2/chrome-session-dump-linux' && sudo chmod 755 /usr/bin/chrome-session-dump

# Nvm, node, npm, yarn etc

read -p "Install nvm (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        nvm install node
        npm i -g standard-version yarn emacs-jsdom-run eslint_d tsc prettier
        ;;
    * )
        echo "Nvm is not installed"
        ;;
esac