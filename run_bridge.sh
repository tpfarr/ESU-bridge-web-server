#!/bin/bash
cd /home/iascaled/esu-bridge
GIT_REV=`git rev-parse --short=6 HEAD`
/usr/bin/python -u esu-bridge.py --config /tmp/protothrottle-config.txt --gitver $GIT_REV

