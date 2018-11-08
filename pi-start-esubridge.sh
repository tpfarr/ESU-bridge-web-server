#!/bin/bash
sudo ntpdate pool.ntp.org
cd /home/iascaled/esu-bridge
cp /boot/protothrottle-config.txt /tmp
./PTlauncher

