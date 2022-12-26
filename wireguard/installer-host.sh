#!/bin/bash

installer_version="22.12.1"
credits="CrunkFX"

own_tunnel() {

  chown 100000:100000 /dev/net/tun

  if [ $? -eq 0 ]; then
    echo "Tunnelrechte erfolgreich angepasst"
  else
    echo "Fehler beim Anpassen der Tunnelrechte"
  fi
}

update_config() {

  if [[ "$proxmox_version" > "7" ]]; then

    if ! grep -q "lxc.mount.entry: /dev/net dev/net none bind,create=dir" "/etc/pve/lxc/$container_choice.conf"; then
      echo "lxc.mount.entry: /dev/net dev/net none bind,create=dir" >>"/etc/pve/lxc/$container_choice.conf"
    else
      echo "dev/net Konfiguration schon vorhanden!"
    fi

    # Proxmox 7 detected
    echo "Proxmox 7 erkannt! Schreibe cgroup2"
    if ! grep -q "lxc.cgroup2.devices.allow: c 10:200 rwm" "/etc/pve/lxc/$container_choice.conf"; then
      echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >>"/etc/pve/lxc/$container_choice.conf"
    else
      echo "cgroup2 schon vorhanden!"
    fi

  else

    # Proxmox < 7 detected
    echo "Proxmox < 7 erkannt! Schreibe legacy cgroup"
    if ! grep -q "lxc.cgroup.devices.allow: c 10:200 rwm" "/etc/pve/lxc/$container_choice.conf"; then
      echo "lxc.cgroup.devices.allow: c 10:200 rwm" >>"/etc/pve/lxc/$container_choice.conf"
    else
      echo "cgroup schon vorhanden!"
    fi
  fi
}

install_prerequisites() {

  if ! command -v whiptail >/dev/null 2>&1; then
    echo
    apt-get update && apt-get install -y whiptail
  fi

  if ! command -v pct >/dev/null 2>&1; then
    apt-get update && apt-get install -y qemu-server qemu-utils
  fi

  if [ $? -eq 0 ]; then
    echo "Abhängigkeiten erfolgreich installiert"
  else
    echo "Fehler beim installieren der Abhängigkeiten"
  fi

}



#### Start section ####
###                 ###

install_prerequisites

# Get the Proxmox version
proxmox_version=$(pveversion | grep -Po '\d+\.\d+')
echo "Proxmox version: $proxmox_version"

# Get a list of all the containers
containers=$(pct list | grep -Po '\d+')
echo "Containers: $containers"

# Use the 'dialog' command to create a menu of containers
whiptail --title "WGUI Installer $installer_version $credits" --msgbox "Willkommen zum Wireguard-UI installer." 10 60
container_choice=$(whiptail --title "Containerauswahl" --menu "Bitte wähle den Container auf dem WireGuard laufen soll!" 0 0 0 $containers 3>&1 1>&2 2>&3)
own_tunnel
update_config

# Check if the user chose a container
if [ -z "$container_choice" ]; then
  echo "Error: Kein Container ausgewählt!"

  exit 1
fi


