#!/bin/bash
###### shellcheck disable=SC1091
#-------------------------------------------------#
#         Check Syncronization of blockchain      #
#                                                 #   
#-------------------------------------------------#
#-------------------------------------------------#
#                  Version: V3.00                 #
#             Donate BitCanna Address:            #
#   bcna14dz7zytpenkyyktqvzq2mw7msfyp0y3zg48xqw   #
#-------------------------------------------------#

#### Rainbowing our lives
bluey=$'\e[94m'
boldy=$'\e[1m'
endy=$'\e[0m'
greeny=$'\e[92m'
greyy=$'\e[37m'
redy=$'\e[91m'
yellowy=$'\e[93m'
export bluey
export boldy
export endy
export greeny
export greyy
export redy
export yellowy

#### Some personalized messages
function bcnatimer { echo -e "${redy}      __   __     _____   ______ \n${redy}     /__/\/__/\  /_____/\/_____/\ \n${redy}     \  \ \\${greeny}: ${redy}\ \_\\${greeny}:::${redy}_${greeny}:${redy}\ \\${greeny}:::${redy}_ \ \ \n${redy}      \\${greeny}::${redy}\_\\${greeny}::${redy}\/_/\  _\\${greeny}:${redy}\|\\${greeny}:${redy}\ \ \ \ \n${redy}       \_${greeny}:::   ${redy}__\/ /${greeny}::${redy}_/__\\${greeny}:${redy}\ \ \ \   \n${redy}            \\${greeny}::${redy}\ \  \\${greeny}:${redy}\____/\\${greeny}:${redy}\_\ \ \  \n${redy}             \__\/   \_____\/\_____\/\n${greeny}     T I M E${endy}" ; }
function erro { echo -e "${boldy}${redy}[ERRO]${endy} ${redy} $* ${endy}"; sleep 1; exit 1; }
function info { echo -e "${boldy}${bluey}[${greyy}INFO${bluey}]${endy} ${greyy} $* ${endy}"; }
function ok   { echo -e "${boldy}${bluey}[${greeny}OK${bluey}]${endy} ${greeny} $* ${endy}"; sleep 0.2; }
function warn { echo -e "${boldy}${bluey}[${yellowy}WARN${bluey}]${endy} ${yellowy} $* ${endy}"; }

if systemctl --all --type service | grep -q cosmovisor ; then
 MYSERVICE="cosmovisor"
elif systemctl --all --type service | grep -q bcnad ; then
 MYSERVICE="bcnad"
fi
info "Check $MYSERVICE.service Running"
if sudo systemctl is-active "$MYSERVICE".service > /dev/null 2>&1 ; then
 ok "$MYSERVICE.service Is Running"
else
 erro "Run: sudo systemctl start $MYSERVICE.service"
fi

info "Syncronizing with Blockchain"
NEEDED="420"
while [ "$(curl -s localhost:26657/status  | jq .result.sync_info.catching_up)" == "true" ]
do 
clear
bcnatimer
warn "!!! PLEASE WAIT TO FULL SYNCRONIZATION !!!"
NODEBLOCK=$(curl -s localhost:26657/status | jq .result.sync_info.latest_block_height | tr -d '"')
CHAINBLOCK=$(curl -s http://seed1.bitcanna.io:26657/status  | jq .result.sync_info.latest_block_height | tr -d '"')
NEEDED="$(("$CHAINBLOCK" - "$NODEBLOCK"))"
info "Remains: $NEEDED Blocks to full syncronization"
sleep 7
done

ok "Syncronized!!"
