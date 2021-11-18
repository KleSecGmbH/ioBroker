#!/bin/sh

##################################
########## Funktionen ############
##################################


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

############# Update

function update_system {
# Updaten
echo -e "\e[1;100m#### 1.   Updates werden geholt und Installiert\e[0m"

echo -e "\e[1;104m#apt update wird ausgführt\e[0m"

apt update > /dev/null
if [ $? -eq 0 ]; then
   echo -e "\e[1;32m#Erfolgreich\e[0m"
else
   echo -e "\e[0;31m#Fehler\e[0m"
fi


echo -e "\e[1;104m#apt upgrade wird ausgführt\e[0m"
apt upgrade -y > /dev/null
if [ $? -eq 0 ]; then
   echo -e "\e[1;32m#Erfolgreich\e[0m"
else
   echo -e "\e[0;31m#Fehler\e[0m"
fi
} 

read -p "                            Wollen Sie fortfahren? (j/n)         " A
if [ "$A" == "" -o "$A" == "j" ] || [ "$A" == "" -o "$A" == "y" ];then

############# Update Ende

############# Pakete laden

function getPackets {
# Pakete laden
echo -e "\e[1;100m#### 2.   Die erforderlichen Pakete werden geladen und installiert\e[0m"
echo ""
echo -e "\e[1;104m#Docker wird installiert\e[0m"
apt install docker.io -y > /dev/null
if [ $? -eq 0 ]; then
   echo -e "\e[1;32m#Erfolgreich\e[0m"
else
   echo -e "\e[0;31m#Fehler\e[0m"
fi

echo -e "\e[1;104m#Docker Compose wird installiert\e[0m"
apt install docker-compose -y > /dev/null
if [ $? -eq 0 ]; then
   echo -e "\e[1;32m#Erfolgreich\e[0m"
else
   echo -e "\e[0;31m#Fehler\e[0m"
fi
}

############# Pakete laden ende

############# WGUI entfernen

function remove_wgui {
docker kill wgui
docker rm wgui
rm -r /root/wireguard-ui
}

############# WGUI entfernen ende

############# WGUI installieren

function install_wgui {
# Wireguard UI Konfigurieren
echo -e "\e[1;100m#### 3.   WireGuard-UI wird installiert\e[0m"
mkdir /root/wireguard-ui
wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/docker-compose.yml -O /root/wireguard-ui/docker-compose.yml
wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.path -O /etc/systemd/system/wgui.path
wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.service -O /etc/systemd/system/wgui.service

cd /root/wireguard-ui

docker-compose up -d


systemctl enable wgui.{path,service}
systemctl start wgui.{path,service}
}

############# WGUI installieren ende

############# Anmeldedaten ändern
function change_pw {
docker kill wgui
rm /root/wireguard-ui/db/server/users.json
read -p "Benutzername eingeben: " user_name
read -s -p "Passwort eingeben: " pass_word
cat << EOF >> /root/wireguard-ui/db/server/users.json
{
        "username": "$user_name",
        "password": "$pass_word"
}
EOF
cd /root/wireguard-ui
docker-compose up -d
}
############# Anmeldedaten ändern

##################################
########### Programm #############
##################################

##====================== Terminal leermachen ========================##
printf "\033c"

##============================= Header ==============================##
print_centered "wireguard-ui-install V1.0.1 Stand 18.11.2021                                                                             2021 forum.iobroker.net/user/crunkfx" " "
echo -e ""

print_centered "-" "-"
print_centered "                                                               " "#"
print_centered "            Willkommen zum WireGuard UI-Installer            " "#"
print_centered "                                                               " "#"
print_centered "-" "-"
##======================= Farben definieren =========================##
echo -e ""
echo -e ""
echo -e ""
print_centered "Dieser Installer wird Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren." " "
echo -e ""
echo -e ""

PS3='Was soll getan werden? : '
options=("WireGuard UI installieren" "WireGuard UI neu-installieren" "WireGuard UI entfernen" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "WireGuard UI installieren")
            change_pw
            #update_system
            #getPackets
            #install_wgui
            exit
            ;;
        "Option 2")
            echo "OK WireGuard UI wird neu-installiert"
            update_system
            getPackets
            remove_wgui
            install_wgui
            break
            ;;
        "Option 3")
            echo "OK WireGuard UI wird entfernt"
            remove_wgui
            ;;
        "Quit")
            break
            ;;
        *) echo "Die Option $REPLY stand nicht zur auswahl :] ";;
    esac
done











else
    echo -e "\e[1;41mInstallation abgebrochen!\e[0m"
    exit 1
fi


