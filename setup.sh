#!/usr/bin/env bash
# Installs all my applications and tweaks on a new Ubuntu Gnome machine.

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CEXIT='\033[0m'

RELEASE=$(lsb_release -cs)

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
install_package 'curl'
install_package 'stow'
install_package 'git'
install_package 'htop'
install_package 'tmux'
install_package 'get-iplayer'
install_package 'youtube-dl'
install_package 'moc'
install_package 'network-manager-openvpn'
install_package 'network-manager-openvpn-gnome'
install_package 'xfonts-terminus'
install_package 'scrot'
install_package 'nautilus-dropbox'
install_package 'mpv'
install_package 'tree'
install_package 'nmap'
install_package 'arc-theme'
install_package 'vagrant'
install_package 'tilix'
install_package 'python3-setuptools'
install_package 'python3-pip'
install_package 'zsh'

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
    sudo apt-get -qq install numix-gtk-theme numix-icon-theme-circle numix-icon-theme-square
    sudo apt-get -qq install numix-folders
    echo -e "${GREEN}Numix is now installed${CEXIT}"
fi

# Spotify
if [ -x /usr/share/spotify/spotify ]; then
    echo -e "${GREEN}Spotify already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Spotify${CEXIT}"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
    sudo echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get -qq install spotify-client
    echo -e "${GREEN}Spotify is now installed${CEXIT}"
fi

# Install Adapta theme
if ls /etc/apt/sources.list.d/tista-ubuntu-adapta-* > /dev/null 2>&1; then
    echo -e "${GREEN}Adapta already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Adapta${CEXIT}"
    sudo add-apt-repository ppa:tista/adapta
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -qq  adapta-*
    echo -e "${GREEN}Adapta is now installed${CEXIT}"
fi

# Remmina install
if [ -f "/usr/bin/remmina" ]; then
    echo -e "${GREEN}Remmina already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Remmina${CEXIT}"
    sudo add-apt-repository ppa:remmina-ppa-team/remmina-next
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -qq  remmina
    echo -e "${GREEN}Remmina is now installed${CEXIT}"
fi

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
    cd /home/$(whoami)/Downloads &&
    sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
    sudo dpkg -i /home/$(whoami)/Downloads/google-chrome-*.deb &&
    sudo apt-get -qq install -f &&
    sudo rm -f /home/$(whoami)/Downloads/google-chrome-*.deb
    echo -e "${GREEN}Google Chrome is now installed${CEXIT}"
fi

# This is needed for shell extensions and has to be done after chrome is installed.
install_package 'chrome-gnome-shell'

# Install Dropbox
if [ -f ~/.dropbox-dist/dropboxd ]; then
    echo -e "${GREEN}Dropbox is already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Dropbox${CEXIT}"
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    echo -e "${GREEN}Dropbox is now installed${CEXIT}"
fi

# Install Virtualbox # Disabled until an Artful PPA is available
if [ -f /usr/bin/virtualbox ]; then
    echo -e "${GREEN}VirtualBox is already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing VirtualBox${CEXIT}"
    echo "deb http://download.virtualbox.org/virtualbox/debian ${RELEASE} contrib" | sudo tee --append /etc/apt/sources.list.d/virtualbox.list
    sudo wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    sudo wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -qq virtualbox-5.2
    echo -e "${GREEN}VirtualBox is now installed${CEXIT}"
fi

# Install Atom editor
if [ -f /usr/bin/atom ]; then
    echo -e "${GREEN}Atom is already installed${CEXIT}"
else
    echo -e "${YELLOW}Installing Atom${CEXIT}"
    sudo add-apt-repository ppa:webupd8team/atom
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -qq atom
    echo -e "${GREEN}Atom is now installed${CEXIT}"
fi

# Install ulancher
if [ -f /usr/bin/ulauncher ]; then
  echo -e "${GREEN}Ulauncher is already installed${CEXIT}"
else
  echo -e "${YELLOW}Installing Ulauncher${CEXIT}"
  sudo add-apt-repository ppa:agornostal/ulauncher
  sudo apt-get update >/dev/null 2>&1
  sudo apt-get install -qq ulauncher
  echo -e "${GREEN}Ulauncher is now installed${CEXIT}"
fi

echo -e "\n${GREEN}${USER} your laptop is now setup!${CEXIT}\n\
${YELLOW}Activate dropbox by running /home/$(whoami)/.dropbox-dist/dropboxd \n${CEXIT}"

echo -e "${YELLOW}Manual installs:\n
ChefDK - \"https://downloads.chef.io/chefdk\"\n\
OHMYZSH - \"http://ohmyz.sh/\"\n\
Powerlevel9k - \"https://github.com/bhilburn/powerlevel9k\"\n\
powerline-fonts - \"https://github.com/powerline/fonts\"\n\
Peek - \"https://github.com/phw/peek\"\n\
pywal - \"sudo pip3 install pywal\"${CEXIT}\n"
