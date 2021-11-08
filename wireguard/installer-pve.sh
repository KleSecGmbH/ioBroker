#!/bin/sh
COLUMNS=$(tput cols) 
title="Hello world!" 
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"

echo -e "\e[1;100mWillkommen Zum Wirguard Easy-Installer\e[0m"
echo -e "\e[100mDieser Installer wird Wireguard-Server, Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren.\e[0m"



read -p "                                           Wollen Sie fortfahren?" A
if [ "$A" == "" -o "$A" == "j" ];then

    # Updaten
echo -e "\e[1;100mUpdates werden goholt und Installiert\e[0m"


apt update
apt upgrade -y

# Pakete laden
echo Die erforderlichen Pakete werden geladen!

apt install docker.io -y
apt install docker-compose -y

# Wireguard UI Konfigurieren
echo Wireguard UI wird installiert!

[ -f /root/wireguard-ui/docker-compose.yml ] || wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/docker-compose.yml -P /root/wireguard-ui
[ -f /etc/systemd/system/wgui.path ] || wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.path -P /etc/systemd/system/
[ -f /etc/systemd/system/wgui.service ] || wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.service -P /etc/systemd/system/

wget git.io/wireguard -O wireguard-install.sh 
bash wireguard-install.sh

else
    echo -e "\e[1;41mInstallation abgebrochen!\e[0m"
    exit 1
fi


