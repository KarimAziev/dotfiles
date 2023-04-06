#!/usr/bin/env bash



read -rp "Install nvm (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        
        ;;
    * )
        echo "Nvm is not installed"
        ;;
esac
