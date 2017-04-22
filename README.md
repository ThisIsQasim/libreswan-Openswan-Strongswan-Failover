# libreswan/Openswan/Strongswan Failover

This script pings the Primary IP address and in case of failure switches the connection, specified in /etc/ipsec.conf, to the Secondary IP. Replace 1.1.1.1 & 0.0.0.0 with your own IPs and run this script with cron.
