#!/usr/bin/env bash

source ./installed.sh


# building telega
if ! (installed pkg-config); then
    sudo apt install -y pkg-config
fi

if ! (installed dwebp); then
    sudo apt install -y dwebp
fi


if ! (installed libappindicator3); then
    sudo apt install -y libappindicator3
fi

if ! (installed tgs2png); then
    sudo apt install -y tgs2png
fi

cd "$HOME" || exit
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install make git zlib1g-dev libssl-dev gperf php-cli cmake clang-14 libc++-dev libc++abi-dev

git clone https://github.com/tdlib/td.git

cd td || exit
rm -rf build
mkdir build
cd build  || exit

CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-14 CXX=/usr/bin/clang++-14 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib ..
cmake --build . --target install
cd ..
cd ..
ls -l td/tdlib
