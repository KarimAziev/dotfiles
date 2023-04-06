#!/usr/bin/env bash


sudo apt update
sudo apt-get update

source ./installed.sh

while read -r repo; do
    sudo apt-add-repository -y "$repo"
done < ./repos.txt

while read -r pkg; do
    if ! (installed "$pkg"); then
        sudo apt install -y "$pkg"
    else
        echo "$pkg already installed"
    fi
done < ./pkgs.txt

