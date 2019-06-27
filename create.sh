#!/bin/bash

ERROR="\033[1;31m[ ERROR ]\033[0m "
WARNING="\033[1;33m[ WARNING ]\033[0m "
INFO="\033[1;34m[ INFO ]\033[0m "
OK="\033[1;32m[ OK ]\033[0m "

if [ "$UID" -eq 0 ]; then
    echo -e $ERROR"This script cannot be run as root"
    exit 1
fi

which pacman &> /dev/null && os="archlinux"
which dnf &> /dev/null && os="fedora"
which apt-get &> /dev/null && os="debian"

echo -e $INFO"Needed packages installation..."
echo -n -e "\033[1;36mroot\033[0m "
if [ "$os" == "archlinux" ]; then
    su -c "sudo pacman --noconfirm -S mailx postfix curl wget file bzip2 gzip unzip python binutils bc jq tmux docker docker-compose"
fi
if [ "$os" == "fedora" ]; then
    su -c "dnf install mailx postfix curl wget file bzip2 gzip unzip python binutils bc jq tmux glibc.i686 libstdc++ libstdc++.i686 docker docker-compose"
fi
if [ "$os" == "debian" ]; then
    su -c "sudo dpkg --add-architecture i386; sudo apt update; sudo apt install mailutils postfix curl wget file bzip2 gzip unzip bsdmainutils python util-linux ca-certificates binutils bc jq tmux lib32gcc1 libstdc++6 libstdc++6:i386 docker docker-compose"
fi

getent passwd "csgoserver" > /dev/null 2&>1

if [ $? -ne 0 ]; then
    echo -e $INFO"Creation of csgoserver user..."
    sudo useradd -m -s /bin/bash csgoserver
    if [ $? -eq 0 ]; then
        echo -e $OK"User csgoserver created"
    else
        echo -e $ERROR"Unable to create csgoserver user"
        exit 1
    fi
    echo -e $INFO"Please enter the password for csgoserver user :"
    echo -n -e "\033[1;36mroot\033[0m "
    su -c "passwd csgoserver"
fi
echo -n -e "\033[1;36mcsgoserver\033[0m "
su csgoserver -c "cd /home/csgoserver && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh csgoserver && ./csgoserver install"
echo -e $INFO"Please put the GSLT login token, you can create one there : \033[1mhttps://steamcommunity.com/dev/managegameservers\033[0m (the game ID is 730)"
read -p "GSLT token : " gslt
read -p "External IPv4 : " ip
file="/home/csgoserver/lgsm/config-lgsm/csgoserver/common.cfg"
echo -n -e "\033[1;36mcsgoserver\033[0m "
su csgoserver -c "echo -e 'ip=\"'$ip'\"' >> $file && echo -e 'gslt=\"'$gslt'\"' >> $file && echo -e 'gametype=\"0\"\ngamemode=\"1\"\ntickrate=\"128\"' >> $file && cd /home/csgoserver && wget https://raw.githubusercontent.com/jffz/docker-ebot/master/docker-compose.yml && sed -i 's/xxx.xxx.xxx.xxx/$ip/g' docker-compose.yml && docker-compose up -d"
