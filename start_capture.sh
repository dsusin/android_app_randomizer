#!/bin/bash
sudo tcpdump -i wlan1 -X -w test.pcap '(udp and port 53) or tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420 or tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354 or tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48545450'
sudo softflowd -d -v 9 -i tun0 -n 127.0.0.1:9995
sudo nfcapd -z -w -l /var/cache/nfdump -S 0
