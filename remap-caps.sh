#!/usr/bin/env bash

filename="/etc/default/keyboard"

if grep XKBOPTIONS= $filename ;
then
    search=$(grep XKBOPTIONS= $filename)
    replace=XKBOPTIONS="\"ctrl:nocaps,grp:toggle\""
    sudo sed -i "s/$search/$replace/" $filename
else
    echo XKBOPTIONS="\"ctrl:nocaps,grp:toggle\"" >> $filename
fi
setxkbmap -option 'ctrl:nocaps,grp:toggle'
sudo dpkg-reconfigure keyboard-configuration