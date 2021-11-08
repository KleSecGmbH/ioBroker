#!/bin/sh

##=== Funktion zum zentrieren von Text von github.com/TrinityCoder ==##
function print_centered {
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }

     declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     printf "%s%s%s" "$filler" "$1" "$filler"
     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n"

     return 0
}

##====================== Terminal leermachen ========================##
printf "\033c"

##============================= Header ==============================##
print_centered "wireguard-pve-install V1.0.0 Stand 08.11.2021                                                                             2021 forum.iobroker.net/user/crunkfx" " "
echo -e ""

print_centered "#" "#"
print_centered "                                                               " "#"
print_centered "            Willkommen zum WireGuard Easy-Installer            " "#"
print_centered "                                                               " "#"
print_centered "#" "#"
##======================= Farben definieren =========================##
echo -e ""
echo -e ""
echo -e ""
print_centered "Dieser Installer wird Wireguard-Server, Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren." " "
echo -e ""
echo -e ""



read -p "                                       Wollen Sie fortfahren? (j/n)         " A
if [ "$A" == "" -o "$A" == "j" ] || [ "$A" == "" -o "$A" == "y" ];then

    # Updaten
echo -e "\e[1;100m#### 1.   Updates werden geholt und Installiert\e[0m"


apt update > /dev/null
apt upgrade -y > /dev/null

# Pakete laden
echo -e "\e[1;100m#### 2.   Die erforderlichen Pakete werden geladen und installiert\e[0m"

apt install docker.io -y > /dev/null
apt install docker-compose -y > /dev/null

# Wireguard UI Konfigurieren
echo -e "\e[1;100m#### 3.   WireGuard-UI wird installiert\e[0m"

[ -f /root/wireguard-ui/docker-compose.yml ] || wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/docker-compose.yml -P /root/wireguard-ui
[ -f /etc/systemd/system/wgui.path ] || wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.path -P /etc/systemd/system/
[ -f /etc/systemd/system/wgui.service ] || wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.service -P /etc/systemd/system/

cd /root/wireguard-ui
docker-compose up -d

# WireGuard Installer Starten
echo -e "\e[1;100m#### 4.   Wireguard Installer wird gestartet\e[0m"
sleep 5
wget git.io/wireguard -O wireguard-install.sh 
bash wireguard-install.sh

else
    echo -e "\e[1;41mInstallation abgebrochen!\e[0m"
    exit 1
fi


