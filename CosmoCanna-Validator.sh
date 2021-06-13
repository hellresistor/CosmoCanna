#!/bin/bash
# shellcheck disable=SC1091
#-------------------------------------------#
#   A BitCanna-Cosmos-Validator Lazy Tool   #
#-------------------------------------------#
#            Version: V1.00                 #
#        Donate BitCanna Address:           #
#--> B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv <-- #
#-------------------------------------------#
. CONFIG

function checkservicestop(){
info "Check $BCNAD.service Stopped"
if sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
 sudo systemctl stop "$BCNAD"
 sudo systemctl disable "$BCNAD"
 ok "$BCNAD Stopped and Disabled"
elif ! sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
 sudo systemctl disable "$BCNAD"
 echo "$BCNAD.service already stopped"
 warn "OOFF"
else
 erro "Something wrong with $BCNAD.service"
fi
}

function gengenesis(){
info "Create/Generate Genesis Account and JSON file"
mkdir -p "$BCNAUSERHOME"/BCNABACKUP/OLDCONFIG
cp -p "$BCNACONF"/genesis.json "$BCNAUSERHOME"/BCNABACKUP/OLDCONFIG/genesis.json."$DATENOW"
cp -rp "$BCNACONF"/gentx/ "$BCNAUSERHOME"/BCNABACKUP/OLDCONFIG/gentx."$DATENOW"
rm -rf "$BCNACONF"/genesis.json
rm -rf "$BCNACONF"/gentx/ 
curl -s "$GENESISLINK" > /tmp/genesis.json || erro "Unable get genesis.json from Stage2 page"
mv /tmp/genesis.json "$BCNACONF"/genesis.json

if "$BCNAD" add-genesis-account "$("$BCNAD" keys show "$WALLETNAME" -a)" 100000000000ubcna ; then
 ok "Genesis Account Added with Success"
else
 erro "Genesis Account Added with Success"
fi
if "$BCNAD" gentx "$WALLETNAME" 90000000000ubcna --moniker "$MONIKER" --chain-id "$CHAINID" -y ; then
 ok "genesis.json generated"
else
 erro "genesis.json NOT generated"
fi

info "Your file are located on this directory: $(find "$BCNACONF"/gentx/ | tail -n1 )"
warn "TIME TO SEND YOUR GENERATED .json file to Network knack"
sleep 1
warn "TIME TO SEND YOUR GENERATED .json file to Network knack"
sleep 1
warn "TIME TO SEND YOUR GENERATED .json file to Network knack"
}

function validsec(){
info "Security to Validator Node"
if sed -E -i "s/persistent_peers = \".*\"/persistent_peers = \"$PERSISTPEERS\"/" "$BCNACONF"/config.toml ; then
 ok "persistent_peers written on $BCNACONF/config.toml"
else
 warn "persistent_peers NOT written on $BCNACONF/config.toml. Chack it Manually"
fi
if sed -E -i "/private_peer_ids =/ s/^#*/#/" "$BCNACONF"/config.toml ; then
 ok "private_peer_ids written on $BCNACONF/config.toml"
else
 warn "private_peer_ids NOT written on $BCNACONF/config.toml. Chack it Manually"
fi
if sed -E -i "s/pex = true/pex = false/" "$BCNACONF"/config.toml ; then
 ok "pex written on $BCNACONF/config.toml"
else
 warn "pex NOT written on $BCNACONF/config.toml. Chack it Manually"
fi
if sed -E -i "s/addr_book_strict = true/addr_book_strict = false/" "$BCNACONF"/config.toml ; then
 ok "addr_book_strict written on $BCNACONF/config.toml"
else
 warn "addr_book_strict NOT written on $BCNACONF/config.toml. Chack it Manually"
fi
}

function questionaire(){
while true
do
info "Welcome To CosmoCanna Lazy-Tool"
info "
Menu:
1- Create/Generate Genesis Account and JSON file
2- Apply Security to Validator Node
3- 

Q- Bye Bye
 
Choice:"
read -r choicy
case $choicy in
 1) checkservicestop
    gengenesis ;;
 2) validsec ;;
 3) ;;
 q|Q) ok "Bye Bye Roll One joint for me ;)" && exit 0 ;;
 *) warn "MISSING KEY"
esac
done
}

###############
###  Start  ###
###############
if [ -z "$MONIKER" ]; then
 erro "Set MONIKER on CONFIG file ..."
fi
if [ -z "$WALLETNAME" ]; then
 erro "Set WALLETNAME on CONFIG file ..."
fi
questionaire
