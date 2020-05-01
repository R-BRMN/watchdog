#!/bin/sh

ver="0.0.6"
CHAT_ID=""
TELEGRAM_API="https://api.telegram.org/bot"
BOT_CREDENTIALS=""
GREETING="Watchdog $ver"
GREETING_JSON="/home/r/scripts/netwatch/menu.json"
LAST_MESSAGE=""

source ./TELEGRAM_SECRET

function sendGreeting() {
        curl -s -X POST $TELEGRAM_API$BOT_CREDENTIALS/sendMessage -d chat_id=$CHAT_ID -d text="$GREETING" -d reply_markup="$(cat $GREETING_JSON)"
}

function sendPhotoGreeting() {
        curl -s -F chat_id=$CHAT_ID -F photo=@"/home/r/scripts/netwatch/logo.jpeg" -F reply_markup="$(cat $GREETING_JSON)" $TELEGRAM_API$BOT_CREDENTIALS/sendPhoto
}

function sendPong() {
        curl -s -X POST $TELEGRAM_API$BOT_CREDENTIALS/sendMessage -d chat_id=$CHAT_ID -d text="Pong"
}

function getUpdates() {
    curl -s -G $TELEGRAM_API$BOT_CREDENTIALS/getUpdates
}

function get_last_callback() {
    getUpdates | jq '.result | .[-1] | .callback_query'
}

function get_last_callback_data() {
        get_last_callback | jq .data | sed -r "s/\"//g"
}

function get_last_callback_id() {
        get_last_callback | jq .id
}

#This should include a check for whether it is a newly issued command
function check_last_callback() {
    last_callback_id=$(get_last_callback_id | grep "\d*")
    #echo "telegram says <$last_callback_id>"
    #echo "tmp says <$(cat /tmp/last_callback_id)>"
    if [ "$last_callback_id" == "$(cat /tmp/last_callback_id)" ]
    then
        #echo "No new command!"
        true
    else
        #echo "Found difference between ID\'s!"
        #echo "tmp file says $(cat /tmp/last_callback_id) while telegram says $last_callback_id"
        sudo echo $last_callback_id > /tmp/last_callback_id
        last_callback_data=$(get_last_callback_data)
        case $last_callback_data in

            "menu")
                sendPhotoGreeting 
                ;;

            "ping")
                sendPong
                ;;

            "nmap_sn")
                sudo /home/r/scripts/netwatch/watchdog.sh "nmap_sn"
                ;;
    
            "nmap_sT_O")
                sudo /home/r/scripts/netwatch/watchdog.sh "nmap_sT_O"
                ;;

            "null")
                ;;
    
            esac
    fi
}

check_last_callback
exit 0
