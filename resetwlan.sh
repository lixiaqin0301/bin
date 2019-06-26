#!/bin/bash
(
flock -n 9 || exit 1
if ping -c 1 www.baidu.com; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') ping www.baiud.com succeed" >> /tmp/resetwlan.log
    exit 0
fi
echo "$(date +'%Y-%m-%d %H:%M:%S') ping www.baidu.com failed" >> /tmp/resetwlan.log
nmcli connection down 802.1x 
echo "$(date +'%Y-%m-%d %H:%M:%S') down 802.1x" >> /tmp/resetwlan.log
nmcli connection up 802.1x 
echo "$(date +'%Y-%m-%d %H:%M:%S') up 802.1x" >> /tmp/resetwlan.log
) 9>/tmp/resetwlan.lock
