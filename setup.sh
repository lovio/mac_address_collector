ash wlan.sh
cat <<EOF > /root/collectmac.awk
#!/usr/bin/awk -f
\$0 ~ /Probe Request/ && \$0 ~ /MHz/ {
        if (\$15 !~ /SA:/) {
                gsub(/\([^\)]*\)/, "")
        }
        if (\$15 ~ /SA:/) {
                gsub(/SA:/, "", \$15)
                gsub(/dB/, "", \$9)
                system("/root/send " \$9 " " \$15 " " \$1)
                #print: \$15, \$9

        }
}
EOF
cat <<EOF > /root/dump.sh
#!/bin/sh

nice -n -17 /usr/sbin/tcpdump -e -i fish0 -s 1500 '(type mgt subtype probe-req)' | awk -f /root/collectmac.awk &
EOF

cat <<EOF > /root/send
#!/bin/sh

MAC=\$(/usr/sbin/iw dev fish0 info | /usr/bin/cut -d ' ' -f 2 | /bin/grep : )

IMAPP_BASE_URL="http://imapp.net/sensor"

if [ -d /home ]; then
    echo "\$MAC \$2 \$1 \$(date '+%Y-%m-%d %T')"  >> /home/collect &
fi
#wget -t 2 -T 2 -q -O /dev/null "\${IMAPP_BASE_URL}?u=\$2&s=\$MAC&a=\$1&t=\$3" 2> /dev/null &
#echo "\$2 \$MAC \$1"  >> /tmp/fifo &
EOF

chmod +x /root/send
chmod +x /root/dump.sh
chmod +x /root/collectmac.awk

cat <<EOF > /etc/init.d/send
#!/bin/sh /etc/rc.common

START=25
STOP=70

SERVICE_DAEMONIZE=1
SERVICE_WRITE_PID=1

IW=/usr/sbin/iw
IFCONFIG=/sbin/ifconfig

start(){
        \$IW phy phy0 interface add fish0 type monitor flags none
        \$IFCONFIG fish0 up
        sleep 5
        /root/dump.sh &
        /bin/echo \$! > /tmp/send.pid
}

stop(){
        /bin/kill \$(cat /tmp/send.pid)
        sleep 2
        \$IFCONFIG fish0 down
        \$IW dev fish0 del
        rm -f /tmp/send.pid
}
EOF

chmod +x /etc/init.d/send

killall tcpdump
killall wget

/etc/init.d/send enable
#/etc/init.d/send start
