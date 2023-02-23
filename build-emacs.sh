#!/usr/bin/env bash
set -o nounset
set -o errexit

echo "$EMACS_DIRECTORY"


install-emacs-deps() {
  echo "Downloading emacs build dependencies..."
   # build-packages
    sudo apt install -y autoconf automake bsd-mailx dbus-x11 debhelper dpkg-dev \
    gcc-10 libacl1-dev libasound2-dev libdbus-1-dev libgccjit-10-dev libgif-dev \
    libgnutls28-dev libgpm-dev libgtk-3-dev libjansson-dev libjpeg-dev \
    liblcms2-dev liblockfile-dev libm17n-dev libncurses5-dev liboss4-salsa2 \
    libotf-dev libpng-dev librsvg2-dev libselinux1-dev libsystemd-dev \
    libtiff-dev libxml2-dev libxpm-dev libxt-dev procps quilt sharutils texinfo \
    zlib1g-dev
  echo "Downloading emacs stage-packages dependencies..."
    # stage-packages:
    sudo apt install -y gvfs libasound2 libaspell15 libasyncns0 \
    libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libbrotli1 libc6 libc6-dev \
    libcairo-gobject2 libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module \
    libcanberra0  libdatrie1 libdb5.3 libdrm2 libegl1 \
    libepoxy0 libflac8 libfontconfig1 libfreetype6 libgbm1 libgccjit0 libgcc-s1 \
    libgdk-pixbuf2.0-0 libgif7 libgl1 libglvnd0 libglx0 libgpm2 libgraphite2-3 \
    libgstreamer-gl1.0-0 libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 \
    libgtk-3-0 libgudev-1.0-0 libharfbuzz-icu0 libharfbuzz0b libhyphen0 libice6 \
    libjansson4 libjbig0 libjpeg-turbo8 liblcms2-2 \
    liblockfile1 libltdl7 libm17n-0 libmpc3 libmpfr6 libnotify4 libnss-mdns \
    libnss-myhostname libnss-systemd libogg0 liborc-0.4-0 libpango-1.0-0\
    libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 libpng16-16 libpulse0 \
    librsvg2-2 libsasl2-2 libsecret-1-0 libsm6 libsndfile1 libsoup2.4-1 \
    libssl1.1 libstdc++6 libtdb1 libthai0 libtiff5 libvorbis0a libvorbisenc2 \
    libvorbisfile3 libwayland-client0 libwayland-cursor0 libwayland-egl1 \
    libwayland-server0 libwebpdemux2 libwoff1 libx11-6 libx11-xcb1 \
    libxau6 libxcb-render0 libxcb-shm0 libxcb1 libxcomposite1 libxcursor1 \
    libxdamage1

    echo "Downloading emacs extra dependencies..."
    sudo apt install -y libwebkit2gtk-4.1-dev w3m mpv curl wget youtube-dl net-tools build-essential autoconf make gcc libgnutls28-dev libtiff5-dev \
          libgif-dev libjpeg-dev libpng-dev libxpm-dev libncurses-dev texinfo libjansson4 libjansson-dev \
          libgccjit0 libgccjit-10-dev gcc-10 g++-10 sqlite3 libconfig-dev \
          libgtk-3-dev gnutls-bin libacl1-dev libotf-dev libxft-dev libsystemd-dev \
          libncurses5-dev libharfbuzz-dev imagemagick libmagickwand-dev xaw3dg-dev libx11-dev \
          libtree-sitter-dev
}



update-emacs() {
    if [ ! -d "$EMACS_DIRECTORY" ];
    then
        echo "Cloning emacs"
        git clone --depth 1 https://git.savannah.gnu.org/git/emacs.git "$EMACS_DIRECTORY"
        cd "$EMACS_DIRECTORY"
    else
        echo "Pulling emacs"
        cd "$EMACS_DIRECTORY"
        sudo make extraclean
        git pull origin "$(git rev-parse --abbrev-ref HEAD)"
    fi

    ./autogen.sh
}

build-emacs() {
   cd "$EMACS_DIRECTORY" 
   CC='gcc-12' ./configure --with-native-compilation --without-compress-install --with-json --with-pgtk --with-xwidgets \
                        --with-cairo --with-gif --with-png --with-jpeg \
                        --with-gnutls --with-modules --with-mailutils \
                        --with-threads --with-included-regex --with-harfbuzz \
                        --with-tiff --with-xpm --with-xft --with-xml2 --with-x-toolkit=gtk3
   make "-j$(nproc)"
}

install-emacs() {
    cd "$EMACS_DIRECTORY" 
    sudo make install
}

