#!/bin/sh
##################################
#            Variablen           #
##################################
INSTAVER="wireguard-ui-install V1.0.1 Stand 18.11.2021     @2021 forum.iobroker.net/user/crunkfx"
# Altes Installationsverzeichnis
OLDDIR="/root/wireguard-ui"

# Neues Installationsverzeichnis
DIR="/opt/wireguard-ui"

##################################
#        Funktionen Start        #
##################################


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
    if [ -d "$OLDDIR" ]; then
        mv $OLDDIR $DIR
        
    fi
    
    if [ -d "$DIR" ]; then
        
        if [ "$(docker ps -aq -f status=running -f name=wgui)" ]; then
            docker kill wgui
        fi
        docker rm wgui
        rm -r /opt/wireguard-ui
        dialog --backtitle "$INSTAVER" \
        --title "Deinstallation abgeschlossen" \
        --msgbox 'Wireguard-UI wurde erfolgreich entfernt!' 15 60
        exit_clear
    else
        
        dialog --title "WireGuard UI ist nicht installiert." \
        --backtitle "$INSTAVER" \
        --yesno "Soll das getan werden?" 15 60
        response=$?
        case $response in
            0) install_wgui ;;
            1) exit_clear ;;
            255) exit_clear ;;
        esac
        
    fi
    
}
############# WGUI entfernen ende

############# WGUI installieren
function install_wgui {
    dialog --title "Wollen Sie fortfahren?" \
    --backtitle "$INSTAVER" \
    --yesno "Dieser Installer wird Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren." 15 60
    response=$?
    case $response in
        0) wgui_installer ;;
        1) exit_clear ;;
        255) exit_clear ;;
    esac
    
    
    
    ############# WGUI installieren ende
    
}

function wgui_installer {
    update_system
    getPackets
    echo -e "\e[1;100m#### 3.   WireGuard-UI wird installiert\e[0m"
    mkdir /root/wireguard-ui
    wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/docker-compose.yml -O /root/wireguard-ui/docker-compose.yml
    wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.path -O /etc/systemd/system/wgui.path
    wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.service -O /etc/systemd/system/wgui.service
    
    cd /root/wireguard-ui
    
    docker-compose up -d
    
    systemctl enable wgui.{path,service}
    systemctl start wgui.{path,service}
    if [ "$(docker ps -aq -f status=running -f name=wgui)" ]; then
        dialog --backtitle "$INSTAVER" \
        --title "Installation abgeschlossen" \
        --msgbox 'Die Installation wurde erfolgreich abgeschlossen!' 15 60
        
    else
        dialog --backtitle "$INSTAVER" \
        --title "ERROR" \
        --msgbox 'Ups. Irgendwas ist da schiefgeleufen ;(' 15 60
    fi
    exit_clear
}

# Anmeldedaten ändern
function change_pw {
    
    # Verschieben falls alter Installationsordner
    if [ -d "$OLDDIR" ]; then
        mv $OLDDIR $DIR
        
    fi
    
    if [ -d "$DIR" ]; then
        
        if [ "$(docker ps -aq -f status=running -f name=wgui)" ]; then
            docker kill wgui
        fi
        rm /opt/wireguard-ui/db/server/users.json
        touch /opt/wireguard-ui/db/server/users.json
        user_name=$(dialog --inputbox "Neuen Benutzernamen eingeben:" 15 60 3>&1 1>&2 2>&3 3>&-)
        pass_word=$(dialog --passwordbox "Neues Passwort eingeben:" 15 60 3>&1- 1>&2- 2>&3-)
        echo -e "{\n                \"username\": \"$user_name\",\n                \"password\": \"$pass_word\"\n}" >>/opt/wireguard-ui/db/server/users.json
        cd /opt/wireguard-ui
        docker-compose up -d
        dialog --backtitle "$INSTAVER" \
        --title "Fertig" \
        --msgbox 'Die Anmeldedaten wurden erfolgreich geändert!' 15 60
        exit_clear
    else
        
        dialog --title "WireGuard UI ist nicht installiert." \
        --backtitle "wireguard-ui-install V1.0.1 Stand 18.11.2021     @2021 forum.iobroker.net/user/crunkfx" \
        --yesno "Soll das getan werden?" 15 60
        response=$?
        case $response in
            0) install_wgui ;;
            1) exit_clear ;;
            255) exit_clear ;;
        esac
        
    fi
    
}

function exit_clear {
    printf "\033c"
    exit
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
DIALOG_TITLE="Willkommen zum WireGuard UI-Installer"
DIALOG_MENU="Was soll getan werden? :"

OPTIONS=(1 "Wireguard UI installieren"
    2 "Wireguard UI deinstallieren"
    3 "Wireguard UI neu-installieren"
    4 "Wireguard UI Anmeldedaten ändern"
    5 "Installer verlassen")

CHOICE=$(dialog --clear \
    --backtitle "$INSTAVER" \
    --title "$DIALOG_TITLE" \
    --menu "$DIALOG_MENU" \
    $DIALOG_HEIGHT $DIALOG_WIDTH $DIALOG_CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
2>&1 >/dev/tty)

clear
case $CHOICE in
    1) install_wgui 
    
    ;;
    
    2)
        remove_wgui
    ;;
    3)
        remove_wgui
        install_wgui
    ;;
    4) change_pw ;;
    5)
        exit_clear
    ;;
esac

##################################
#        Start Dialog Ende       #
##################################
