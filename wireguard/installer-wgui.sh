#!/bin/sh
##################################
#            Variablen           #
##################################



# Altes Installationsverzeichnis
OLDDIR="/root/wireguard-ui"

# Neues Installationsverzeichnis
DIR="/opt/wireguard-ui"

##################################
#        Funktionen Start        #
##################################

##=== Funktion zum zentrieren von Text von github.com/TrinityCoder ==##
function print_centered {
    [[ $# == 0 ]] && return 1

    declare -i TERM_COLS="$(tput cols)"
    declare -i str_len="${#1}"
    [[ $str_len -ge $TERM_COLS ]] && {
        echo "$1"
        return 0
    }

    declare -i filler_len="$(((TERM_COLS - str_len) / 2))"
    [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
    filler=""
    for ((i = 0; i < filler_len; i++)); do
        filler="${filler}${ch}"
    done

    printf "%s%s%s" "$filler" "$1" "$filler"
    [[ $(((TERM_COLS - str_len) % 2)) -ne 0 ]] && printf "%s" "${ch}"
    printf "\n"

    return 0
}

############# Update
function update_system {
    # Updaten
    echo -e "\e[1;100m#### 1.   Updates werden geholt und Installiert\e[0m"

    echo -e "\e[1;104m#apt update wird ausgführt\e[0m"

    apt update >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m#Erfolgreich\e[0m"
    else
        echo -e "\e[0;31m#Fehler\e[0m"
    fi

    echo -e "\e[1;104m#apt upgrade wird ausgführt\e[0m"
    apt upgrade -y >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m#Erfolgreich\e[0m"
    else
        echo -e "\e[0;31m#Fehler\e[0m"
    fi
}
############# Update Ende

############# Pakete laden
function getPackets {
    # Pakete laden
    echo -e "\e[1;100m#### 2.   Die erforderlichen Pakete werden geladen und installiert\e[0m"
    echo ""
    echo -e "\e[1;104m#Docker wird installiert\e[0m"
    apt install docker.io -y >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m#Erfolgreich\e[0m"
    else
        echo -e "\e[0;31m#Fehler\e[0m"
    fi

    echo -e "\e[1;104m#Docker Compose wird installiert\e[0m"
    apt install docker-compose -y >/dev/null
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
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
    print_centered "Dieser Installer wird Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren." " "
    echo -e ""

    read -p "                            Wollen Sie fortfahren? (j/n)         " A
    if [ "$A" == "" -o "$A" == "j" ] || [ "$A" == "" -o "$A" == "y" ]; then

        echo -e "\e[1;100m#### 3.   WireGuard-UI wird installiert\e[0m"
        mkdir /root/wireguard-ui
        wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/docker-compose.yml -O /root/wireguard-ui/docker-compose.yml
        wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.path -O /etc/systemd/system/wgui.path
        wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.service -O /etc/systemd/system/wgui.service

        cd /root/wireguard-ui

        docker-compose up -d

        systemctl enable wgui.{path,service}
        systemctl start wgui.{path,service}
    fi

    ############# WGUI installieren ende

}

# Anmeldedaten ändern
function change_pw {

    if [ -d "$OLDDIR" ]; then
        mv $OLDDIR $DIR

    fi

    if [ -d "$DIR" ]; then

        if [ "$(docker ps -aq -f status=running -f name=wgui)" ]; then
            docker kill wgui
        fi
        rm /opt/wireguard-ui/db/server/users.json
        user_name=$(dialog --inputbox "Neuen Benutzernamen eingeben:" 10 30 3>&1- 1>&2- 2>&3-)
        pass_word=$(dialog --passwordbox "Neues Passwort eingeben:" 10 30 3>&1- 1>&2- 2>&3-)
        cat <<-'EOF' >/opt/wireguard-ui/db/server/users.json
                {
                        "username": "$user_name",
                        "password": "$pass_word"
                }
EOF

        cd /opt/wireguard-ui
        docker-compose up -d

    else
        read -p "                            WireGuard UI ist nicht installiert. Soll das getan werden? (j/n)         " A
        if [ "$A" == "" -o "$A" == "j" ] || [ "$A" == "" -o "$A" == "y" ]; then
            install_wgui
        fi
    fi

}
# Anmeldedaten ändern ende

##################################
#        Funktionen Ende         #
##################################

#=======================================================================================================================

##################################
#         Programm Start         #
##################################

# Dialog installieren
apt install dialog
export LANG=C.UTF-8
# ============================== #
##################################
#         Start Dialog           #
##################################

DIALOG_HEIGHT=15
DIALOG_WIDTH=60
DIALOG_CHOICE_HEIGHT=4
DIALOG_BACKTITLE="wireguard-ui-install V1.0.1 Stand 18.11.2021     @2021 forum.iobroker.net/user/crunkfx" " "
DIALOG_TITLE="Willkommen zum WireGuard UI-Installer"
DIALOG_MENU="Was soll getan werden? :"

OPTIONS=(1 "Wireguard UI installieren"
    2 "Wireguard UI deinstallieren"
    3 "Wireguard UI neu-installieren"
    4 "Wireguard UI Anmeldedaten ändern"
    4 "Installer verlassen")

CHOICE=$(dialog --clear \
    --backtitle "$DIALOG_BACKTITLE" \
    --title "$DIALOG_TITLE" \
    --menu "$DIALOG_MENU" \
    $DIALOG_HEIGHT $DIALOG_WIDTH $DIALOG_CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >/dev/tty)

clear
case $CHOICE in
1) ;;

\
    2)
    echo "You chose Option 2"
    ;;
3)
    echo "You chose Option 3"
    ;;
4)
    change_pw
    ;;
5)
    printf "\033c"
    exit
    ;;
esac

##################################
#        Start Dialog Ende       #
##################################

