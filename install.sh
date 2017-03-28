#!/usr/bin/env bash
# Installs all my applications and tweaks on a new Ubuntu Gnome machine. 

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CEXIT='\033[0m' 

RELEASE=`lsb_release -r | sed -e 's/Release:\s//'`
ARCFILE="/etc/apt/sources.list.d/arc-theme.list"
LOG=/tmp/new_install.log

# Update repos
echo -e "\n$YELLOW Updating repos.... $CEXIT\n"
sudo apt -qq update

# check for root or sudo
#if [[ $EUID -ne 0 ]]; then
#    echo -e "\n$RED You are not root! Please re run as root or sudo. $CEXIT\n"
#    exit 1
#fi

# SSH check and setup
function ssh_setup() {
    if [ -f /home/$(whoami)/.ssh/config ]; then
        sudo find /home/$(whoami)/.ssh -type d -exec chmod 700 {} \;
        sudo find /home/$(whoami)/.ssh -type f -exec chmod 600 {} \;
        echo -e "\n$GREEN ssh keys are installed and have correct permissions\n $CEXIT"
    else
        echo -e "\n$RED Please copy your ssh keys and config file to the .ssh dir\n $CEXIT"
        exit 1
    fi
}

ssh_setup

# User details for .gitconfig
read -p " Please enter your full name: " NAME
read -p " Please enter your email address: " EMAILADDRESS
echo -e "\n$GREEN Hello there $NAME, shall we begin....\n $CEXIT"
sleep 2

# Create projects dir
function project_dir() {
    if [ -d /home/$(whoami)/projects ]; then
        echo -e "$GREEN Projects dir already created $CEXIT"
    else
        echo -e "$YELLOW Creating projects dir $CEXIT"
    mkdir -p /home/$USER/projects >> $LOG 2>&1
    fi
}

project_dir

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
install_package 'git' install_package 'htop'
install_package 'tmux'
install_package 'remmina'
install_package 'youtube-dl'
install_package 'get-iplayer'
install_package 'network-manager-openvpn'
install_package 'network-manager-openvpn-gnome'
install_package 'xfonts-terminus'

# Clone dotfiles repo and setup .gitconfig
function clone_dots() {
    if [ ! -d /home/$(whoami)/dotfiles ]; then
        git clone git@github.com:$(whoami)eastaugh/dotfiles.git /home/$(whoami)/dotfiles
    fi
    git config --global user.name "$NAME"
    git config --global user.email $EMAILADDRESS
    git config --global push.default simple
}

# Apply dots
function apply_dots() {
    if [ -f /home/$(whoami)/.bashrc.backup ]; then    
        cd /home/$(whoami)/dotfiles
        stow bash vim tmux mpv moc
    else
        mv /home/$(whoami)/.bashrc /home/$(whoami)/.bashrc.backup >> $LOG 2>&1
        cd /home/$(whoami)/dotfiles
        stow bash vim tmux mpv moc
    fi
}

clone_dots
apply_dots

# Install Monaco fonts

if [ -d "/usr/share/fonts/truetype/ttf-monaco" ]; then
    echo -e "$GREEN Monaco fonts are already installed $CEXIT"
else
    echo -e "$YELLOW Installing Monaco fonts $CEXIT"
    sudo mkdir -p /usr/share/fonts/truetype/ttf-monaco; cd /usr/share/fonts/truetype/ttf-monaco/
    sudo wget http://www.gringod.com/wp-upload/software/Fonts/Monaco_Linux.ttf
    sudo mkfontdir
    cd /usr/share/fonts/truetype/
    fc-cache
    echo -e "$GREEN Monaco fonts are now installed. System restart may be required $CEXIT"
fi

# Numix theme and icons
if ls /etc/apt/sources.list.d/numix* > /dev/null 2>&1; then
    echo -e "$GREEN Numix already installed $CEXIT"
else
    echo -e "$YELLOW Installing Numix theme and icons $CEXIT"
    add-apt-repository ppa:numix/ppa
    apt-get -qq update
    apt-get -qq install numix-gtk-theme numix-icon-theme-circle numix-folders numix-icon-theme-square
    echo -e "$GREEN Numix is now installed $CEXIT"
fi 

# Spotify
if [ -x /usr/share/spotify/spotify ]; then
    echo -e "$GREEN Spotify already installed $CEXIT"
else
    echo -e "$YELLOW Installing Spotify $CEXIT"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    apt-get -qq update
    apt-get -qq install spotify-client
    echo -e "$GREEN Spotify is now installed $CEXIT"
fi

function arc_install() {
    if [ $RELEASE != "16.10" ]; then
        if [ -s "$ARCFILE" ]; then
            echo -e "$GREEN arc-theme from PPA is already installed $CEXIT"
        else
            echo -e "$YELLOW Installing arc-theme from PPA $CEXIT"
            wget -O http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key /tmp/Release.key
            sudo apt-key add - < /tmp/Release.key
            sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list"
            sudo apt-get -qq update
            sudo apt-get -qq install arc-theme
            echo -e "$GREEN arc-theme from PPA is now installed $CEXIT"
        fi
    else
        if dpkg-query --list | grep -m1 "arc-theme"; then
            echo -e "$GREEN arc-theme from apt source already intalled $CEXIT"
        else
            echo -e "$YELLOW Installing arc-theme using apt install $CEXIT"
            sudo apt -qq update
            sudo apt -qq install arc-theme
            echo -e "$GREEN arc-theme from apt is now installed $CEXIT"
        fi
    fi
}

arc_install 

# Etcher
if [ -f "/etc/apt/sources.list.d/etcher.list" ]; then
    echo -e "$GREEN Etcher already installed $CEXIT"
else
    echo -e "$YELLOW Installing Etcher $CEXIT"
    echo "deb https://dl.bintray.com/resin-io/debian stable etcher" > /etc/apt/sources.list.d/etcher.list
    sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 379CE192D401AB61
    sudo apt-get update
    apt-get install etcher-electron
    echo -e "$GREEN Etcher is now installed $CEXIT"
fi

echo -e "\n$GREEN $USER your laptop is now setup! $CEXIT\n\
$YELLOW Remember to manually switch to the arc theme and select your fonts!\n $CEXIT"
