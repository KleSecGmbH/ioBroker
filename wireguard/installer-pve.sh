#!/bin/sh

# Updaten
echo Update wird ausgeführt!

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

wget git.io/wireguard -O wireguard-install.sh && bash wireguard-install.sh
echo hallo