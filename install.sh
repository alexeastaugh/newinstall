#!/usr/bin/env bash
# Installs all my applications and tweaks on a new Ubuntu Gnome machine. 

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CEXIT='\033[0m' 

RELEASE=`lsb_release -c | sed -e 's/Codename:\s//'`
ARCFILE="/etc/apt/sources.list.d/arc-theme.list"
LOG=/tmp/new_install.log

# Update repos
echo -e "\n${YELLOW}Updating repos.... ${CEXIT}\n"
sudo apt update >/dev/null 2>&1

# SSH check and setup
function ssh_setup() {
    if [ -f /home/$(whoami)/.ssh/config ]; then
        sudo find /home/$(whoami)/.ssh -type d -exec chmod 700 {} \;
        sudo find /home/$(whoami)/.ssh -type f -exec chmod 600 {} \;
        echo -e "\n${GREEN}ssh keys are installed and have correct permissions\n${CEXIT}"
    else
        echo -e "\n${RED}Please copy your ssh keys and config file to the .ssh dir${CEXIT}"
        exit 1
    fi
}

ssh_setup

# User details for .gitconfig
read -p "Please enter your full name: " NAME
read -p "Please enter your email address: " EMAILADDRESS
echo -e "\n${GREEN}Hello there ${NAME}, shall we begin....\n${CEXIT}"
sleep 2

# Create projects dir
function project_dir() {
    if [ -d /home/$(whoami)/projects ]; then
        echo -e "${GREEN}Projects dir already created${CEXIT}"
    else
        echo -e "${YELLOW}Creating projects dir${CEXIT}"
    mkdir -p /home/${USER}/projects >> ${LOG} 2>&1
    fi
}

project_dir

# Install apt packages
function install_package() {
    if dpkg-query --list | sed 's/ii  //g' | grep -m1 -q ^"$1"; then
        echo -e "${GREEN}$1 is already installed${CEXIT}"
    else
        echo -e "${YELLOW}Installing $1${CEXIT}"
        sudo apt install --assume-yes "$@" >> ${LOG} 2>&1
    fi
}

install_package 'vim'
install_package 'stow'
install_package 'git'
install_package 'htop'
install_package 'tmux'
install_package 'remmina'
install_package 'get-iplayer'
install_package 'moc'
install_package 'network-manager-openvpn'
install_package 'network-manager-openvpn-gnome'
install_package 'xfonts-terminus'
install_package 'scrot'
install_package 'nautilus-dropbox'

# Clone dotfiles repo and setup .gitconfig
function clone_dots() {
    if [ ! -d /home/$(whoami)/dotfiles ]; then
        git clone git@github.com:$(whoami)eastaugh/dotfiles.git /home/$(whoami)/dotfiles
    fi
    git config --global user.name "${NAME}"
    git config --global user.email ${EMAILADDRESS}
    git config --global push.default simple
}

# Apply dots
function apply_dots() {
    if [ -f /home/$(whoami)/.bashrc.backup ]; then    
        cd /home/$(whoami)/dotfiles
        stow bash vim tmux mpv moc
    else
        mv /home/$(whoami)/.bashrc /home/$(whoami)/.bashrc.backup >> ${LOG} 2>&1
        cd /home/$(whoami)/dotfiles
        stow bash vim tmux mpv moc
    fi
}

clone_dots
apply_dots

# Install Monaco fonts
if [ -d "/usr/share/fonts/truetype/ttf-monaco" ]; then
    echo -e "${GREEN}Monaco fonts are already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Monaco fonts${CEXIT}"
    sudo mkdir -p /usr/share/fonts/truetype/ttf-monaco; cd /usr/share/fonts/truetype/ttf-monaco/
    sudo wget http://www.gringod.com/wp-upload/software/Fonts/Monaco_Linux.ttf
    sudo mkfontdir
    cd /usr/share/fonts/truetype/
    fc-cache
    echo -e "${GREEN}Monaco fonts are now installed. System restart may be required${CEXIT}"
fi

# Numix theme and icons
if ls /etc/apt/sources.list.d/numix* > /dev/null 2>&1; then
    echo -e "${GREEN}Numix already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Numix theme and icons${CEXIT}"
    sudo add-apt-repository ppa:numix/ppa
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get -qq install numix-gtk-theme numix-icon-theme-circle numix-folders numix-icon-theme-square
    echo -e "${GREEN}Numix is now installed${CEXIT}"
fi 

# Spotify
if [ -x /usr/share/spotify/spotify ]; then
    echo -e "${GREEN}Spotify already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Spotify${CEXIT}"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    sudo echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get -qq install spotify-client
    echo -e "${GREEN}Spotify is now installed${CEXIT}"
fi

function arc_install() {
    if [ ${RELEASE} != "yakkety" ]; then
        if [ -s "${ARCFILE}" ]; then
            echo -e "${GREEN}arc-theme from PPA is already installed${CEXIT}"
        else
            echo -e "${YELLOW}Installing arc-theme from PPA${CEXIT}"
            sudo wget http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key --output-document=/tmp/Release.key
            sudo apt-key add - < /tmp/Release.key
            sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list"
            sudo apt-get update >/dev/null 2>&1
            sudo apt-get -qq install arc-theme
            echo -e "${GREEN}arc-theme from PPA is now installed${CEXIT}"
        fi
    else
        if dpkg-query --list | grep -m1 "arc-theme" > /dev/null; then
            echo -e "${GREEN}arc-theme from apt source already intalled${CEXIT}"
        else
            echo -e "${YELLOW}Installing arc-theme using apt install${CEXIT}"
            sudo apt -qq install arc-theme
            echo -e "${GREEN}arc-theme from apt is now installed${CEXIT}"
        fi
    fi
}

arc_install 

# Etcher
if [ -f "/etc/apt/sources.list.d/etcher.list" ]; then
    echo -e "${GREEN}Etcher already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Etcher${CEXIT}"
    echo "deb https://dl.bintray.com/resin-io/debian stable etcher" | sudo tee --append /etc/apt/sources.list.d/etcher.list
    sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 379CE192D401AB61
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -qq etcher-electron
    echo -e "${GREEN}Etcher is now installed${CEXIT}"
fi

# Install Google Chrome
if [ -f "/usr/bin/google-chrome" ]; then
    echo -e "${GREEN}Google Chrome is already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Google Chrome${CEXIT}"
    sudo cd /home/$(whoami)/Downloads &&
    sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
    sudo dpkg -i /home/$(whoami)/Downloads/google-chrome-*.deb &&
    sudo apt-get -qq install -f &&
    sudo rm -f /home/$(whoami)/Downloads/google-chrome-*.deb
    echo -e "${GREEN}Google Chrome is now installed${CEXIT}"
fi

# Install Dropbox
if [ -f ~/.dropbox-dist/dropboxd ]; then
    echo -e "${GREEN}Dropbox is already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Dropbox${CEXIT}"
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    echo -e "${GREEN}Dropbox is now installed${CEXIT}"
fi

# Install youtube-dl
if [ -f /usr/local/bin/youtube-dl ]; then
    echo -e "${GREEN}youtube-dl is already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing youtube-dl${CEXIT}"
    sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    sudo chmod a+rx /usr/local/bin/youtube-dl
    echo -e "${GREEN}youtube-dl is now installed${CEXIT}"
fi

# Install Virtualbox
if [ -f /usr/bin/virtualbox ]; then
    echo -e "${GREEN}VirtualBox is already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing VirtualBox${CEXIT}"
    echo "deb http://download.virtualbox.org/virtualbox/debian ${RELEASE} contrib" | sudo tee --append /etc/apt/sources.list.d/virtualbox.list
    sudo wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    sudo wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -qq virtualbox-5.1
    echo -e "${GREEN}VirtualBox is now installed${CEXIT}"
fi

echo -e "\n${GREEN}${USER} your laptop is now setup!${CEXIT}\n\
${YELLOW}Remember to manually switch to the arc theme and select your fonts! \
Also you need to activate dropbox by running /home/$(whoami)/.dropbox-dist/dropboxd \n${CEXIT}"
