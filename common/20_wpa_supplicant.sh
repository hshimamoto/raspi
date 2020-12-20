#!/bin/bash

echo "Setup wpa_supplicant"

. /config

# set country
echo "country=JP" >> /etc/wpa_supplicant/wpa_supplicant.conf

# WPA_SSID and WPA_PASS
/common/21_wap_supplicant_sub.sh 4 $WPA_SSID0 $WPA_PASS0
/common/21_wap_supplicant_sub.sh 3 $WPA_SSID1 $WPA_PASS1
/common/21_wap_supplicant_sub.sh 2 $WPA_SSID2 $WPA_PASS2
/common/21_wap_supplicant_sub.sh 1 $WPA_SSID3 $WPA_PASS3
/common/21_wap_supplicant_sub.sh 0 $WPA_SSID4 $WPA_PASS4
