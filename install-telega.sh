#!/bin/bash


function installed() {
    return $(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')
}


# building telega
if !(installed pkg-config); then
    sudo apt install -y pkg-config
fi

if !(installed dwebp); then
    sudo apt install -y dwebp
fi


if !(installed libappindicator3); then
    sudo apt install -y libappindicator3
fi

if !(installed tgs2png); then
    sudo apt install -y tgs2png
fi

cd $HOME
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install make git zlib1g-dev libssl-dev gperf php-cli cmake clang-14 libc++-dev libc++abi-dev
git clone https://github.com/tdlib/td.git
cd td
rm -rf build
mkdir build
cd build
CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-14 CXX=/usr/bin/clang++-14 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib ..
cmake --build . --target install
cd ..
cd ..
ls -l td/tdlib
