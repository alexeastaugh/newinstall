#!/usr/bin/env bash
# Installs all my applications and tweaks on a new Ubuntu Gnome machine. 

# variables
LOG=/tmp/new_install.log
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CEXIT='\033[0m' 

# check for root or sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "\n$RED You are not root! Please re run as root or sudo. $CEXIT\n"
    exit 1 >> $LOG 2>&1
fi

# SSH check and setup
function ssh_setup() {
    if [ -f /home/alex/.ssh/config ]; then
        sudo find /home/alex/.ssh -type d -exec chmod 700 {} \; >> $LOG 2&>1
        sudo find /home/alex/.ssh -type f -exec chmod 660 {} \; >> $LOG 2&>1
        echo -e "\n$GREEN ssh keys are installed and have correct permissions\n $CEXIT"
    else
        echo -e "\n$RED Please copy your ssh keys and config file to the .ssh dir\n $CEXIT"
        exit 1 >> $LOG 2>&1
    fi
}

ssh_setup

# User details for .gitconfig
#read -p "Please enter your full name:" NAME
#read -p "Please enter your email address:" EMAILADDRESS
#echo -e "\n$GREEN Hello there $NAME, shall we begin....\n $CEXIT"
#sleep 5

# Install apt packages
function install_package() {
    if dpkg-query --list | grep -m1 -q "$1"; then
        echo -e "$GREEN $1 is already installed $CEXIT"
    else
        echo -e "$YELLOW Installing $1 $CEXIT"
        sudo apt install --assume-yes "$@" >> $LOG 2>&1
    fi
}

install_package 'vim'
install_package 'stow'
install_package 'git'
install_package 'htop'
install_package 'tmux'
install_package 'remmina'
install_package 'youtube-dl'
install_package 'get-iplayer'
install_package 'network-manager-openvpn'
install_package 'network-manager-openvpn-gnome'

# Clone dotfiles repo
function clone_dots() {
    if [ ! -d /home/alex/dotfiles ]; then
        git clone git@github.com:alexeastaugh/dotfiles.git /home/alex/dotfiles
    fi
    git config --global user.name $NAME
    git config --global user.email $EMAILADDRESS
    git config --global push.default simple
}

# Apply dots
function apply_dots() {
    if [ -f /home/alex/.bashrc.backup ]; then    
        cd /home/alex/dotfiles
        stow bash vim tmux mpv moc
    else
        mv /home/alex/.bashrc /home/alex/.bashrc.backup >> $LOG 2>&1
        cd /home/alex/dotfiles
        stow bash vim tmux mpv moc
    fi
}

clone_dots
apply_dots

# Create projects dir
echo -e "\n$GREEN Creating projects dir $CEXIT"
mkdir -p /home/$USER/projects >> $LOG 2>&1

# TODO
# package installs with PPA's

echo -e "\n$GREEN Everything is now setup! $CEXIT"
