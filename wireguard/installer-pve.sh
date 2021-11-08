#!/bin/sh

##========================== Variablen =============================##

BLANK='\033[0m'
YELLOW='\033[1;33m'
GRAY='\033[0;37m'
GRAY_R='\033[39m'
WHITE_R='\033[39m'
RED='\033[1;31m' # Light Red.
GREEN='\033[1;32m' # Light Green.
BOLD='\e[1m'


##====================== Terminal leermachen ========================##
printf "\033c"

##======================= Farben definieren =========================##
echo -e "wireguard-pve-install V1.0.0 Stand 08.11.2021                                                                             2021 forum.iobroker.net/user/crunkfx"
echo -e ""
echo -e ""
echo -e "\t\t\t\t\tWillkommen zum WireGuard Easy-Installer"
echo -e ""
echo -e "\e[100m\t\t\tDieser Installer wird Wireguard-Server, Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren.\e[0m"



read -p "                                  Wollen Sie fortfahren?" A
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


