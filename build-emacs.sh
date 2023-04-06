#!/usr/bin/env bash

EMACS_DIRECTORY="$HOME/emacs"



if [ -z "$DOTFILES_ROOT" ]; then
    DOTFILES_ROOT=$HOME/dotfiles
fi


cd DOTFILES_ROOT || exit
set -o errexit
set -o pipefail


installed() {
    return "$(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')"
}

copy-emacs-icon(){
    filename="/usr/local/share/applications/emacs.desktop"
    replace="Icon=$DOTFILES_ROOT/icons/emacs.png"
    if [ -f "$DOTFILES_ROOT/icons/emacs.png" ]; then
           search=$(grep Icon=emacs "$filename")
           if grep Icon=emacs "$filename"; then
           sudo sed -i "s|$search|$replace|" "$filename"
      fi
    fi
}


install-emacs-deps() {
    pkgs=(libwebkit2gtk-4.1-dev build-essential autoconf make gcc libgnutls28-dev \
                                libtiff5-dev libgif-dev libjpeg-dev libpng-dev libxpm-dev libncurses-dev texinfo \
                                libjansson4 libjansson-dev libgccjit0 libgccjit-10-dev gcc-10 g++-10 sqlite3 \
                                libconfig-dev libgtk-3-dev gnutls-bin libacl1-dev libotf-dev libxft-dev \
                                libsystemd-dev libncurses5-dev libharfbuzz-dev imagemagick libmagickwand-dev \
                                xaw3dg-dev libx11-dev libtree-sitter-dev automake bsd-mailx dbus-x11 debhelper \
                                dpkg-dev libasound2-dev libdbus-1-dev libgpm-dev liblcms2-dev liblockfile-dev \
                                libm17n-dev liboss4-salsa2 librsvg2-dev libselinux1-dev libtiff-dev libxml2-dev \
                                libxt-dev procps quilt sharutils zlib1g-dev gvfs libasound2 libaspell15 \
                                libasyncns0 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libbrotli1 libc6 \
                                libc6-dev libcairo-gobject2 libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module \
                                libcanberra0 libdatrie1 libdb5.3 libdrm2 libegl1 libepoxy0 libflac8 \
                                libfontconfig1 libfreetype6 libgbm1 libgcc-s1 libgdk-pixbuf2.0-0 libgif7 libgl1 \
                                libglvnd0 libglx0 libgpm2 libgraphite2-3 libgstreamer-gl1.0-0 \
                                libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgtk-3-0 libgudev-1.0-0 \
                                libharfbuzz-icu0 libharfbuzz0b libhyphen0 libice6 libjbig0 libjpeg-turbo8 \
                                liblcms2-2 liblockfile1 libltdl7 libm17n-0 libmpc3 libmpfr6 libnotify4 \
                                libnss-mdns libnss-myhostname libnss-systemd libogg0 liborc-0.4-0 libpango-1.0-0 \
                                libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 libpng16-16 libpulse0 \
                                librsvg2-2 libsasl2-2 libsecret-1-0 libsm6 libsndfile1 libsoup2.4-1 libssl1.1 \
                                libstdc++6 libtdb1 libthai0 libtiff5 libvorbis0a libvorbisenc2 libvorbisfile3 \
                                libwayland-client0 libwayland-cursor0 libwayland-egl1 libwayland-server0 \
                                libwebpdemux2 libwoff1 libx11-6 libx11-xcb1 libxau6 libxcb-render0 libxcb-shm0 \
                                libxcb1 heif-gdk-pixbuf libxcomposite1 libxcursor1 libxdamage1)

    for pkg in "${pkgs[@]}"; do
        if ! (installed "$pkg"); then
            sudo apt install -y "$pkg"
        else
            echo "skipping install $pkg"
        fi
    done
}

kill-emacs () {
    if pgrep emacs >/dev/null ; then
        echo "Emacs is running."
        read -pr "Do you want to kill Emacs? [y/n] " answer
        case ${answer:0:1} in
            y|Y )
                echo "Killing Emacs..."
                pkill emacs
                echo "Emacs killed."
                ;;
            * )
                echo "Not killing Emacs."
                ;;
        esac
    else
        echo "Emacs is not running."
    fi
}

update-emacs() {
    if [ ! -d "$EMACS_DIRECTORY" ];
    then
        echo "Cloning emacs"
        git clone --depth 1 https://git.savannah.gnu.org/git/emacs.git "$EMACS_DIRECTORY"
        cd "$EMACS_DIRECTORY" || exit
    else
        cd "$EMACS_DIRECTORY" || exit
        echo "Cleanup emacs"
        sudo make extraclean
        echo "Pulling emacs"
        git pull origin "$(git rev-parse --abbrev-ref HEAD)"
    fi
}

build-emacs() {
    cd "$EMACS_DIRECTORY" || exit
    ./autogen.sh
    CC='gcc-12' ./configure --with-native-compilation=aot \
      --without-compress-install --with-json --with-pgtk --with-xwidgets \
      --with-cairo --with-gif --with-png --with-jpeg \
      --with-gnutls --with-modules --with-mailutils \
      --with-threads --with-included-regex --with-harfbuzz \
      --with-tiff --with-xpm --with-xft --with-xml2 --with-x-toolkit=gtk3
    make "-j$(nproc)"
}

install-emacs() {
    cd "$EMACS_DIRECTORY" || exit
    sudo make install
    copy-emacs-icon
}


build-emacs-interactive () {
    read -rp "Compile emacs (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            install-emacs-deps;
            kill-emacs;
            update-emacs;
            build-emacs;
            read -rp "Install emacs (y/n)? " ans
            case ${ans:0:1} in
                y|Y )
                    cd "$EMACS_DIRECTORY" || exit
                    sudo make install
                    ;;
                * )
                    echo "Skipping installing"
                    ;;
            esac
            ;;
        * )
            echo "Emacs is not configured"
            ;;
    esac
}

