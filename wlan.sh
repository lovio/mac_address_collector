uci set wireless.@wifi-device[0].country='CN'
uci set wireless.@wifi-device[0].disabled=0
uci set wireless.@wifi-iface[0].network='lan'
uci set wireless.@wifi-iface[0].mode='ap'
uci set wireless.@wifi-iface[0].ssid='wakaka'
uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.@wifi-iface[0].key='team90TEAM'
uci set wireless.@wifi-iface[0].hidden=0

uci set wireless.@wifi-device[1].country='CN'
uci set wireless.@wifi-device[1].disabled=0
uci set wireless.@wifi-device[1].channel=165
uci set wireless.@wifi-iface[1].network='wwan'
uci set wireless.@wifi-iface[1].mode='sta'
uci set wireless.@wifi-iface[1].ssid='Sensoro5G'
uci set wireless.@wifi-iface[1].encryption='psk2'
uci set wireless.@wifi-iface[0].key='team90TEAM'

uci set network.lan.ifname='eth0.1 wlan0'

uci commit

mv /dev/random /dev/random.orig
ln -s /dev/urandom /dev/random

/etc/init.d/network restart
