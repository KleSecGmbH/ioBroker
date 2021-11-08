#!/bin/sh
for i in {16..21} {21..16} ; do echo -en "\e[41;5;${i}m \e[0m" ; done ; echo

echo -e "\e[1;100m                              Willkommen Zum Wirguard Easy-Installer"
echo -e "\e[100mDieser Installer wird Wireguard-Server, Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren."

for i in {16..21} {21..16} ; do echo -en "\e[41;5;${i}m \e[0m" ; done ; echo

read -p "                                           Wollen Sie fortfahren?" A
if [ "$A" == "" -o "$A" == "j" ];then

    # Updaten
echo -e "\e[1;100mUpdates werden goholt und Installiert"


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
    echo -e "\e[1;41mInstallation abgebrochen!"
    exit 1
fi


