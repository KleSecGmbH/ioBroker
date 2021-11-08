WireGuard auf Proxmox UI
 Installationszeit | ca. 15 Minuten je nach Internetverbindung
---- | ----
 Stand | 08.11.2021
ioBroker Forum Link | https://forum.iobroker.net/topic/49177/anleitung-wireguard-mit-wireguard-ui-auf-proxmox

**Voraussetzungen:**

* Proxmox als Grundgerüst
* Einen Dual-Stack Internetanschluss (**also kein DS-Lite, hierzu kommt bei Bedarf eine gesonderte Anleitung**)
* Portfreigabe im Router (Protokoll: **UDP**, Port: **51820** , auf die IP Adresse des neuen Linux Containers)
  **!!! Keine Portfreigabe auf den im späteren Verlauf erstellten Port 5000 setzen !!!**
* Falls keine feste IP vorhanden ist benötigt ihr einen Hostnamen. Das kann z.b. MyFritz sein oder DynDns, Hauptsache ein Dienst mit dem ihr auf eure aktuelle IP verweisen könnt.

**Anleitung:**

[**Linux Container/CT Anlegen**]
Zunächst müssen wir das LXC Template für Ubuntu 21.04 oder 21.10 installieren.
![23a3f946-e4a5-474a-a547-6958fa6c692b-image.png](https://forum.iobroker.net/assets/uploads/files/1636289981715-23a3f946-e4a5-474a-a547-6958fa6c692b-image.png) 
![3fb3bf2a-9774-45c6-b75b-3225ab5e816a-image.png](https://forum.iobroker.net/assets/uploads/files/1636290035337-3fb3bf2a-9774-45c6-b75b-3225ab5e816a-image.png) 
Anschließend basierend auf diesem Image einen neuen Container anlegen
![25a469ce-ffa4-4ce4-8579-f82a26de4b89-image.png](https://forum.iobroker.net/assets/uploads/files/1636290074626-25a469ce-ffa4-4ce4-8579-f82a26de4b89-image.png) 
einen Hostnamen vergeben sowie ein Passwort
![8d3d3004-0642-49ec-a769-a316d4297118-image.png](https://forum.iobroker.net/assets/uploads/files/1636290108082-8d3d3004-0642-49ec-a769-a316d4297118-image.png) 
Danach das Image auswählen
![e7c06c25-6059-423f-bd14-844678c0e382-image.png](https://forum.iobroker.net/assets/uploads/files/1636290138013-e7c06c25-6059-423f-bd14-844678c0e382-image.png) 
Und mit den Standardwerten bis zur Netzwerkkonfiguration weitermachen.
![8d03a6b7-3e7a-4a07-9b84-f13fa3af28f5-image.png](https://forum.iobroker.net/assets/uploads/files/1636290154894-8d03a6b7-3e7a-4a07-9b84-f13fa3af28f5-image.png) 
![cd74e576-f949-4463-a69a-1597ba0bee81-image.png](https://forum.iobroker.net/assets/uploads/files/1636290168043-cd74e576-f949-4463-a69a-1597ba0bee81-image.png) 
![f95aff1e-1e0e-4da8-885e-7568a8df179a-image.png](https://forum.iobroker.net/assets/uploads/files/1636290181714-f95aff1e-1e0e-4da8-885e-7568a8df179a-image.png) 
Nun noch eine IP vergeben und der erste Teil wäre geschafft.
![8bc94ae4-1c5f-409d-bbbd-06ff2135d3f0-image.png](https://forum.iobroker.net/assets/uploads/files/1636290237184-8bc94ae4-1c5f-409d-bbbd-06ff2135d3f0-image.png) 


[**WireGuard & WireGuard-UI Installation**]
**Ab hier wird auf dem Proxmox Host gearbeitet!**

Zunächst  passen wir die Konfiguration des neu erstellten Containers an.
Dazu mit dem Befehl
```
nano /etc/pve/lxc/100.conf
```
**(!! 100 durch die Nummer bei eurem Container ersetzen !!)**

die Konfigurationsdatei anpassen. 
![a65c3fd4-81aa-4728-af46-16f5c42366fc-image.png](https://forum.iobroker.net/assets/uploads/files/1636290318009-a65c3fd4-81aa-4728-af46-16f5c42366fc-image.png) 
Und diese beiden Zeilen am Ende der Datei anhängen:
```
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
```
![1aa5c539-812d-4779-9366-bdebbbdc0449-image.png](https://forum.iobroker.net/assets/uploads/files/1636290365488-1aa5c539-812d-4779-9366-bdebbbdc0449-image.png) 

Nach dem Einfügen das Fenster mit **STRG** + **X** --> **Enter** speichern und verlassen.

Danach auf dem Proxmox Host die Zugriffsrechte für den Tunneladapter freigeben mit dem Befehl: 
```
chown 100000:100000 /dev/net/tun
```
___
**Ab hier wird auf dem neuen Container gearbeitet!**

Bevor wir den Container starten, müssen wir 2 Einstellungen vornehmen damit Docker auf dem Container lauffähig ist.
Dazu müssen wir in den Container Einstellungen die Features bearbeiten
![73d6da3a-5f61-499e-8617-846c185c0c57-image.png](https://forum.iobroker.net/assets/uploads/files/1636291770075-73d6da3a-5f61-499e-8617-846c185c0c57-image.png) 
und die Punkte **keyctl** und **Nesting** aktivieren.
![df1e862f-af0c-4b6c-81ea-1d1e5e5b0dcc-image.png](https://forum.iobroker.net/assets/uploads/files/1636291793958-df1e862f-af0c-4b6c-81ea-1d1e5e5b0dcc-image.png) 
Danach können wir unseren LXC/CT starten und uns anmelden.

Ich habe alle zur Installation notwendigen Befehle und Konfigurationsdateien in einem kleinen Shell-Skript zusammengefügt.
Dazu also folgendes ausführen:
```
wget https://raw.githubusercontent.com/KleSecGmbH/ioBroker/main/wireguard/installer-pve.sh -O installer-pve.sh && bash installer-pve.sh
```
Der Installer läuft bis zu diesem Punkt automatisch durch. Die abgefragten Punkte wie im Bild gezeigt beantworten.
![0d8fa718-1ece-4745-aec7-94fcbdda4ec1-image.png](https://forum.iobroker.net/assets/uploads/files/1636368893614-0d8fa718-1ece-4745-aec7-94fcbdda4ec1-image.png) 
Wer nach der Wireguard Installation einen QR-Code sieht, hat bis dato schonmal alles richtig gemacht. Der angezeigte QR-Code kann soweit ignoriert werden, da wir mit WireGuard UI arbeiten.


[**WireGuard-UI Konfiguration**]
Nachdem wir erfolgreich WireGuard und WireGuard-UI Installiert haben, können wir WireGuard-UI Konfigurieren.

Dazu rufen wir *http://**IP-AdresseVomLinuxContainer**:5000* auf und melden uns mit Benutzer und Passwort **admin** an.

Zunächst müssen wir den WireGuard Server Konfigurieren. Dazu muss in den Global Settings unter dem Punkt Endpoint-Address euer Hostname(MyFritz, DynDns) oder eine feste IP (falls vorhanden) **Bei Fragen hierzu siehe oben!**
![8de68576-79f6-4a70-b7f6-bdf31d921f8f-image.png](https://forum.iobroker.net/assets/uploads/files/1636370027824-8de68576-79f6-4a70-b7f6-bdf31d921f8f-image-resized.png) 
Nachdem wir Hostname/IP eingegeben haben und auf **Apply Config** geklickt haben, müssen wir noch einen kleinen Punkt durchführen um Clients anlegen zu können.

Dazu im Fenster WireGuard Server unter dem Punkt **Post Up Script** folgendes eintragen:
```
iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
und um Feld **Post Down Script** folgendes eintragen:
```
iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
![0fd33499-0c08-4957-bdb0-793707a58e14-image.png](https://forum.iobroker.net/assets/uploads/files/1636370635094-0fd33499-0c08-4957-bdb0-793707a58e14-image-resized.png) 
Danach speichern und **Apply Config** drücken.


***Clients anlegen:***

Ab hier dürfte alles recht selbsterklärend sein.
Im Menü WireGuard Clients auf **New Client** drücken
![377d8ef8-46b8-4529-95b6-bef2138920dd-image.png](https://forum.iobroker.net/assets/uploads/files/1636370817674-377d8ef8-46b8-4529-95b6-bef2138920dd-image-resized.png) 
Name und Email Konfigurieren
![1a4718cc-3dca-4f2f-9cc5-547b66d513d6-image.png](https://forum.iobroker.net/assets/uploads/files/1636370935431-1a4718cc-3dca-4f2f-9cc5-547b66d513d6-image.png) 
und Bestätigen.

Nun bekommt ihr einen Client mit einem QR Code den ihr mit der WireGuard App scannen könnt oder alternativ als Datei zum Download für Desktoprechner.

![ee5aaacd-cca2-4320-95aa-ac9a65a54351-image.png](https://forum.iobroker.net/assets/uploads/files/1636370995143-ee5aaacd-cca2-4320-95aa-ac9a65a54351-image.png)
 
