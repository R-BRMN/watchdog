#!/bin/sh

CHAT_ID=""
REPORT="/tmp/watchdog_scan"
TMP="/tmp/watchdog_tmp"
BOT_CREDENTIALS=""

source ./TELEGRAM_SECRET

#Until there's choice - choice is nmap_sn
SCAN_TYPE=$1

case $SCAN_TYPE in

	nmap_sn)
		sudo nmap -v -sn --max-retries 1 192.168.0.0/24 > /tmp/$SCAN_TYPE
				
		grep "MAC\|report" /tmp/$SCAN_TYPE | grep -v "down" > $REPORT &&
		sed n\;G $REPORT | sudo tee $REPORT &&
		head -n -2 $REPORT | sudo tee $TMP ; sudo mv $TMP $REPORT &&
		devices=$(sudo sed -r "s/Nmap.*for\ (\S*)($|\.015.*)/\1/" $REPORT | sed -r "s/MAC.*ss\:\ (.*)/\1/")
		;;

	nmap_sT_O)
		sudo sh -c "nmap -v -sT -O --max-retries 3 192.168.0.0/24 > /tmp/$SCAN_TYPE"
		devices=''
		;;


	esac

curl -s -F chat_id="$CHAT_ID" -F caption="$devices" -F document=@"/tmp/$SCAN_TYPE" https://api.telegram.org/bot$BOT_CREDENTIALS/sendDocument
