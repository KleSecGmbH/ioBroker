#!/bin/bash

wgui_service_creator() {
  echo -e "[Unit]\nDescription=Restart WireGuard\nAfter=network.target\n\n[Service]\nType=oneshot\nExecStart=$(which systemctl) restart wg-quick@wg0.service\n\n[Install]\nRequiredBy=wgui.path" >/etc/systemd/system/wgui.service
  echo -e "[Unit]\nDescription=Watch /etc/wireguard/wg0.conf for changes\n\n[Path]\nPathModified=/etc/wireguard/wg0.conf\n\n[Install]\nWantedBy=multi-user.target" >/etc/systemd/system/wgui.path

  systemctl enable wgui.{path,service}
  systemctl start wgui.{path,service}
  systemctl enable wireguard-ui
  systemctl start wireguard-ui

  # Check the service active state
  WGUI_WEB_ACTIVE_STATE=$(systemctl is-active --full wireguard-ui | grep "Active" | awk '{print $3}')
  echo $WGUI_WEB_ACTIVE_STATE

  WGUI_SERVICE_STATUS=$(systemctl is-active --full wgui | grep "Active" | awk '{print $2}')
  if [ "$WGUI_SERVICE_STATUS" == "active" ]; then
    # Service is running
    echo "WireGuard UI service is running."
  else
    # Service is not running
    echo "WireGuard UI service is not running."
    systemctl status wireguard-ui


  fi
}

get_wgui() {
  wgui_latest_release=$(curl -s "https://api.github.com/repos/ngoduykhanh/wireguard-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  echo "Latest release: $wgui_latest_release"
  architecture=$(uname -m)

  case "$architecture" in
  "i386" | "i686")
    release_url="https://github.com/ngoduykhanh/wireguard-ui/releases/download/$wgui_latest_release/wireguard-ui-$wgui_latest_release-linux-386.tar.gz"
    echo "Using URL: $release_url"
    ;;
  "x86_64")
    release_url="https://github.com/ngoduykhanh/wireguard-ui/releases/download/$wgui_latest_release/wireguard-ui-$wgui_latest_release-linux-amd64.tar.gz"
    echo "Using URL: $release_url"
    ;;
  "armv7l" | "aarch64")
    release_url="https://github.com/ngoduykhanh/wireguard-ui/releases/download/$wgui_latest_release/wireguard-ui-$wgui_latest_release-linux-arm.tar.gz"
    echo "Using URL: $release_url"
    ;;
  *)
    echo "Error: Unsupported architecture $architecture"
    exit 1
    ;;

  esac

  wget $release_url --waitretry=30 -O wireguard-ui.tar.gz --show-progress
  tar -xzf wireguard-ui.tar.gz
  mkdir $INSTALL_LOCATION
  mv wireguard-ui $INSTALL_LOCATION/wireguard-ui.bin
  rm wireguard-ui.tar.gz
}

select_install_dir() {
  INSTALL_LOCATION="/opt/wireguard-ui"
  INSTALL_LOCATION=$(whiptail --inputbox "Enter the installation location:" 8 78 "$INSTALL_LOCATION" 3>&1 1>&2 2>&3)
  # Check if the user entered a location
  if [ -n "$INSTALL_LOCATION" ]; then
    # User entered a location
    echo "Selected installation location: $INSTALL_LOCATION"
  else
    # User cancelled the dialog
    echo "No installation location selected."
  fi

  echo "Installationsverzeichnis: : $INSTALL_LOCATION"
}

###########################
#      Main Functions     #
install_wgui() {

  select_install_dir

  # create wgui main service
  echo -e "[Unit]\nAfter=network.target\n\n[Service]\nWorkingDirectory=$INSTALL_LOCATION\nExecStart=$INSTALL_LOCATION/wireguard-ui.bin\n\n[Install]\nWantedBy=default.target" >/etc/systemd/system/wireguard-ui.service

  get_wgui
  apt install -y wireguard
  wgui_service_creator

}

check_wgui() {

  # check if wgui is already installed as a service
  systemctl list-unit-files | grep -q wireguard-ui.service
  if [ $? -eq 0 ]; then
    if whiptail --yesno "WGUI ist bereits installiert. Neu installieren?" 8 78; then
      echo "WGUI wird installiert"
      install_wgui
    else
      echo "Installtion abgebrochen!"
      exit 1
    fi
  else
    install_wgui
  fi
}

###########################
###### Start Section ######
###########################

# check for root
if [ "$(id -u)" -eq 0 ]; then

  apt update
  apt install -y wget curl tar coreutils whiptail

  selection=$(whiptail --title "Function menu" --menu "Choose a function:" 15 60 4 \
    "1" "Wireguard UI installieren" \
    "2" "Wireguard installieren" \
    "3" "Wireguard UI entfernen" \
    "4" "Wireguard & WGUI entfernen" --clear 3>&1 1>&2 2>&3)

  # Run the selected function
  case "$selection" in
  "1") check_wgui ;;
  "2") install_prerequisites ;;
  "3") install_wireguard ;;
  esac

else

  echo "Dieses Skript muss als root ausgeführt werden."
  exit 1
fi
