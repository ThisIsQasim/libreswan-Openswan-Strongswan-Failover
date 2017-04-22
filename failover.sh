#!/bin/bash

#This script pings the Primary IP address and in case of failure
#switches the connection, specified in /etc/ipsec.conf, to the SecondaryIP
#Specify both the IPs below and run this script with cron.

PRIMARYIP="1.1.1.1"
SECONDARYIP="0.0.0.0"

HOST=$PRIMARYIP
#Number of ping requests
COUNT=5
RIGHTIP=$PRIMARYIP

COUNT=$(ping -c 5 202.125.139.10 | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
echo "$(date)"

        if [ $COUNT -eq 5 ]
                then
                echo "Host : $HOST is up with 0 packet loss, checking if the right configuration is up"
                RIGHTIP=$(cat /etc/ipsec.conf | grep right=202 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
                if [ "$RIGHTIP" = "$PRIMARYIP" ]; then
                echo "The right configuration is up"
                else
                        if [ "$RIGHTIP" = "$SECONDARYIP" ]; then
                        echo "The backup configuration is up, loading the main configuration"
                        #code for changing ipsec.conf
                        sed -i -e "s/${RIGHTIP}/${PRIMARYIP}/g" /etc/ipsec.conf
                        systemctl restart ipsec
                        else
                        echo "The configuration is messed up, reloading original configuration"
                        #code for reload
                        sed -i -e "s/${RIGHTIP}/${PRIMARYIP}/g" /etc/ipsec.conf
                        systemctl restart ipsec
                        fi
                fi
        else
                        if [ $COUNT -lt 3 ]; then
                        RIGHTIP=$(cat /etc/ipsec.conf | grep right=202 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
                        echo "Host : $HOST is down with more than 30% packet loss, checking if the backup configuration is up"
                        if [ "$RIGHTIP" = "$SECONDARYIP" ]; then
                        echo "The backup configuration is up"
                        else
                                if [ "$RIGHTIP" = "$PRIMARYIP" ]; then
                                echo "The main configuration is up, changing to backup"
                                #code for changing ipsec.conf
                        	sed -i -e "s/${RIGHTIP}/${SECONDARYIP}/g" /etc/ipsec.conf
                                systemctl restart ipsec
                                else
                                echo "The configuration is messed up, reloading original backup configuration"
                                #code for reload
                        	sed -i -e "s/${RIGHTIP}/${SECONDARYIP}/g" /etc/ipsec.conf
                                systemctl restart ipsec
                                fi

                        fi
                        fi
        fi

exit
