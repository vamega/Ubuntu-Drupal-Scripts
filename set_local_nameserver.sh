#!/bin/bash
sed '1i\
nameserver 127.0.0.1' /etc/resolv.conf > /etc/resolv.conf.temp
mv /etc/resolv.conf.temp /etc/resolv.conf
