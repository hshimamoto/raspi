#!/bin/bash

echo "Start setup in CHROOT"
echo "TEMPLATE: wifiap"

if [ -e /config ]; then
	. /config
fi

echo "NAME: $NAME"

# non interactive
export DEBIAN_FRONTEND=noninteractive

/common/01_package_update.sh
/common/02_essential_package.sh
/common/10_hostname.sh $NAME
/common/11_ssh.sh
/common/12_hdmi.sh
/common/13_wifi.sh

systemctl disable wpa_supplicant.service

apt-get install -y hostapd dnsmasq iptables-persistent
sed -e "s/WIFIAP_SSID/$WIFIAP_SSID/" \
	-e "s/WIFIAP_PASS/$WIFIAP_PASS" \
	/template/hostapd.conf > /etc/hostapd/hostapd.conf

systemctl unmask hostapd
systemctl enable hostapd

cp /template/default.hostapd /etc/default/hostapd

cat <<_EOF_ > /etc/network/interfaces.d/wlan0
auto wlan0
iface wlan0 inet static
  address 192.168.88.1
  netmask 255.255.255.0
  broadcase 192.168.88.255
_EOF_

cat <<_EOF_ > /etc/dnsmasq.conf
interface=wlan0
domain=raspiwifi.local
dhcp-range=192.168.88.10,192.168.88.99,12h
dhcp-option=option:router,192.168.88.1
dhcp-option=option:dns-server,192.168.88.1
_EOF_

cat <<_EOF_ > /etc/iptables/rules.v4
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 192.168.88.0/24 ! -d 192.168.88.0/24 -j MASQUERADE
COMMIT
_EOF_

cat <<_EOF_ > /etc/sysctl.d/wifiap.conf
net.ipv4.ip_forward=1
_EOF_

/common/99_cleanup.sh

echo "End"
