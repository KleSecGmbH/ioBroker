#!/bin/sh
##################################
#            Variablen           #
##################################
INSTAVER="wireguard-easy-install V1.2.0 Stand 02.01.2022     @2022 forum.iobroker.net/user/crunkfx"
# Altes Installationsverzeichnis
OLDDIR="/root/wireguard-ui"

# Neues Installationsverzeichnis
DIR="/opt/wireguard-ui"
FILE="/opt/wireguard-ui/wireguard-ui"



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

############# WGUI entfernen
function remove_wgui {
    if [ -d "$DIR" ]; then
        service wireguard-ui stop
        rm /etc/systemd/system/wireguard-ui.service
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
function remove_wgui_toReinstall {
    rm -r /opt/wireguard-ui
    install_wgui
}

function keepFilesandReinstall {
    rm /opt/wireguard-ui/wireguard-ui
    install_wgui
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

function keepfiles {
    if [ -f "$FILE" ]; then
        dialog --title "Konfiguration vorhanden!" \
        --backtitle "$INSTAVER" \
        --yesno "Sollen die Konfigurationsdateien behalten werden?" 15 60
        response=$?
        case $response in
            0) keepFilesandReinstall ;;
            1) remove_wgui_toReinstall ;;
            255) exit_clear ;;
        esac
    else
        install_wgui
    fi
    
}

function wgui_installer {
    
    if [ -f "$FILE" ]; then
        dialog --title "WireGuard UI ist bereits installiert." \
        --backtitle "$INSTAVER" \
        --yesno "Soll es erneut installiert werden?" 15 60
        response=$?
        case $response in
            0) keepfiles ;;
            1) exit_clear ;;
            255) exit_clear ;;
        esac
    fi
    systemctl stop wireguard-ui
    update_system
    echo -e "\e[1;100m#### 3.   WireGuard-UI wird installiert\e[0m"
    mkdir /opt/wireguard-ui
    arch=$(uname -m)
    if [[ $arch == x86_64* ]]; then
        wget https://github.com/ngoduykhanh/wireguard-ui/releases/download/v0.3.5/wireguard-ui-v0.3.5-linux-amd64.tar.gz -O /opt/wireguard-ui/install.tar.gz
        elif [[ $arch == i*86 ]]; then
        wget https://github.com/ngoduykhanh/wireguard-ui/releases/download/v0.3.5/wireguard-ui-v0.3.5-linux-386.tar.gz -O /opt/wireguard-ui/install.tar.gz
        elif  [[ $arch == arm* ]]; then
        wget https://github.com/ngoduykhanh/wireguard-ui/releases/download/v0.3.5/wireguard-ui-v0.3.5-linux-arm.tar.gz -O /opt/wireguard-ui/install.tar.gz
    fi
    wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui.path -O /etc/systemd/system/wgui.path
    if [ -d "/usr/bin/systemctl" ]; then
    wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui-usr.service -O /etc/systemd/system/wgui.service
    else
    wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wgui-bin.service -O /etc/systemd/system/wgui.service     
    fi
    
    wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/wireguard-ui.service -O /etc/systemd/system/wireguard-ui.service
    
    cd /opt/wireguard-ui
    tar -xf install.tar.gz
    rm install.tar.gz
    
    systemctl daemon-reload
    systemctl enable wgui.{path,service}
    systemctl start wgui.{path,service}
    systemctl enable wireguard-ui
    systemctl start wireguard-ui
    
    if systemctl is-active --quiet wireguard-ui ; then
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
    
    
    if [ -f "$FILE" ]; then
        systemctl stop wireguard-ui
        rm /opt/wireguard-ui/db/server/users.json
        touch /opt/wireguard-ui/db/server/users.json
        user_name=$(dialog --inputbox "Neuen Benutzernamen eingeben:" 15 60 3>&1 1>&2 2>&3 3>&-)
        pass_word=$(dialog --passwordbox "Neues Passwort eingeben:" 15 60 3>&1- 1>&2- 2>&3-)
        echo -e "{\n                \"username\": \"$user_name\",\n                \"password\": \"$pass_word\"\n}" >>/opt/wireguard-ui/db/server/users.json
        systemctl daemon-reload
        systemctl start wireguard-ui
        dialog --backtitle "$INSTAVER" \
        --title "Fertig" \
        --msgbox 'Die Anmeldedaten wurden erfolgreich geändert!' 15 60
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

function exit_clear {
    printf "\033c"
    exit
}

function complete_install {
    dialog --title "Wollen Sie fortfahren?" \
    --backtitle "$INSTAVER" \
    --yesno "Dieser Installer wird Wireguard-Server, Wireguard-UI, sowie alle notwendigen Pakete und Paketquellen laden und installieren." 15 60
    response=$?
    case $response in
        0) wginstallercomplete ;;
        1) exit_clear ;;
        255) exit_clear ;;
    esac
}

function wginstallercomplete {
    install_wgui
    echo -e "\e[1;100m####   Wireguard Installer wird gestartet\e[0m"
    sleep 5
    wget git.io/wireguard -O wireguard-install.sh
    bash wireguard-install.sh
    
}

function wginstaller {
    echo -e "\e[1;100m####   Wireguard Installer wird gestartet\e[0m"
    sleep 5
    wget git.io/wireguard -O wireguard-install.sh
    bash wireguard-install.sh
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
# ALten Ordner verschieben
if [ -d "$OLDDIR" ]; then
    mv $OLDDIR $DIR
    
fi
#=============================== #
##################################
#         Start Dialog           #
##################################

DIALOG_HEIGHT=30
DIALOG_WIDTH=60
DIALOG_CHOICE_HEIGHT=4
DIALOG_TITLE="Willkommen zum WireGuard Easy-Installer"
DIALOG_MENU="Was soll getan werden? :"

OPTIONS=(1 "Komplettpaket installieren"
    2 "Wireguard installation anpassen"
    3 "Wireguard UI installieren"
    4 "Wireguard UI deinstallieren"
    5 "Wireguard UI aktualisieren"
    6 "Wireguard UI Anmeldedaten ändern"
7 "Installer verlassen")

CHOICE=$(dialog --clear \
    --backtitle "$INSTAVER" \
    --title "$DIALOG_TITLE" \
    --menu "$DIALOG_MENU" \
    $DIALOG_HEIGHT $DIALOG_WIDTH $DIALOG_CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
2>&1 >/dev/tty)

clear
case $CHOICE in
    1) wginstallercomplete ;;
    2) wginstaller ;;
    3) install_wgui ;;
    4) remove_wgui ;;
    5) keepfiles ;;
    6) change_pw ;;
    7) exit_clear ;;
esac

##################################
#        Start Dialog Ende       #
##################################

