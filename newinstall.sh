#!/usr/bin/env bash
# Installs all my applications and tweaks on a new Ubuntu Gnome machine. 
# variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
COLOUREX='\033[0m' 

# check for root or sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "\n$RED You are not root! Please re run as root or sudo. $COLOUREX\n"
    exit 1
fi # Numix theme and icons
if [ -f "/etc/apt/sources.list.d/numix-ubuntu-ppa-yakkety.list" ]; then
    echo -e "\n$GREEN ### Numix already installed ### $COLOUREX"
else
    echo -e "\n$YELLOW ### Installing Numix theme and icons ### $COLOUREX"
    add-apt-repository ppa:numix/ppa
    apt-get update
    apt-get install numix-gtk-theme numix-icon-theme-circle numix-folders
    echo -e "\n$GREEN ### Numix is now installed ### $COLOUREX"
fi # Spotify
if [ -x /usr/share/spotify/spotify ]; then
    echo -e "\n$GREEN ### Spotify already installed ### $COLOUREX"
else
    echo -e "\n$YELLOW ### Installing Spotify ### $COLOUREX"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    apt-get update
    apt-get install spotify-client
    echo -e "\n$GREEN ### Spotify is now installed ### $COLOUREX"
fi # Arc theme
if ! grep -q arc-theme /etc/apt/sources.list.d/*; then
    echo -e "\n$GREEN ### arc-theme already installed ### $COLOUREX"
else
    echo -e "\n$YELLOW ### Installing arc-theme ### $COLOUREX"
    sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/arc-theme.list"
    sudo apt-get update
    sudo apt-get install arc-theme
    echo -e "\n$GREEN ### arc-theme is now installed ### $COLOUREX"
fi # Etcher
if [ -f "/etc/apt/sources.list.d/etcher.list" ]; then
    echo -e "\n$GREEN ### Etcher already installed ### $COLOUREX"
else
    echo -e "\n$YELLOW ### Installing Etcher ### $COLOUREX"
    apt-get install etcher-electron
    echo "\n$GREEN ### Etcher is now installed ###$COLOUREX"
fi
