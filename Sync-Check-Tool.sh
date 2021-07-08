#!/bin/bash
# shellcheck disable=SC1091
#-------------------------------------------------#
#         Check Syncronization of blockchain      #
#                                                 #   
#-------------------------------------------------#
#-------------------------------------------------#
#                  Version: V2.00                 #
#             Donate BitCanna Address:            #
#   bcna14dz7zytpenkyyktqvzq2mw7msfyp0y3zg48xqw   #
#-------------------------------------------------#

. CONFIG

info "Check bcnad.service/cosmovisor.service Running"
if sudo systemctl is-active bcnad.service > /dev/null 2>&1 || sudo systemctl is-active cosmovisor.service > /dev/null 2>&1 ; then
 ok "bcnad/cosmovisor service Running"
else
 erro "bcnad/cosmovisor.service Not Running. Run it first..."
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
