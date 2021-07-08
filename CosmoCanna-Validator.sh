#!/bin/bash
# shellcheck disable=SC1091
#-------------------------------------------#
#   A BitCanna-Cosmos-Validator Lazy Tool   #
#-------------------------------------------#
#            Version: V1.00                 #
#        Donate BitCanna Address:           #
#--> B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv <-- #
#-------------------------------------------#

########
# EDIT #
MONIKER="" ## Set Your Moniker## 
WALLETNAME="$MONIKER" ## Set Your Name Wallet
CHAINID="bitcanna-testnet-5"  ## Set correct testnet
########

. CONFIG

function varys(){
BCNACOSMOSREP="testnet-bcna-cosmos"
BCNACOSMOSLINK=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep 'browser_download_url' | cut -d\" -f4)
GENESISLINK="https://raw.githubusercontent.com/BitCannaGlobal/$BCNACOSMOSREP/main/instructions/stage5/genesis.json"
PERSISTPEERS="d6aa4c9f3ccecb0cc52109a95962b4618d69dd3f@seed1.bitcanna.io:26656,41d373d03f93a3dc883ba4c1b9b7a781ead53d76@seed2.bitcanna.io:16656" # Comma separated values Ex: 123,123,123,123
SEEDS="d6aa4c9f3ccecb0cc52109a95962b4618d69dd3f@seed1.bitcanna.io:26656,41d373d03f93a3dc883ba4c1b9b7a781ead53d76@seed2.bitcanna.io:16656"
BCNAUSERHOME="$HOME"
BCNADIR="$BCNAUSERHOME/.bcna"
BCNACONF="$BCNADIR/config"
BCNADATA="$BCNADIR/data"
BCNAD="bcnad"
BCNAPORT="26656"
SCRPTVER="V1.00"
DONATE="B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv"
DATENOW=$(date +"%Y%m%d%H%M%S")
VPSIP=$(curl -s ifconfig.me)
}

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
 warn "persistent_peers NOT written on $BCNACONF/config.toml. Check it Manually"
fi
if sed -E -i "/private_peer_ids =/ s/^#*/#/" "$BCNACONF"/config.toml ; then
 ok "private_peer_ids written on $BCNACONF/config.toml"
else
 warn "private_peer_ids NOT written on $BCNACONF/config.toml. Check it Manually"
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
varys
if [ -z "$MONIKER" ]; then
 erro "Set MONIKER on CONFIG file ..."
fi
if [ -z "$WALLETNAME" ]; then
 erro "Set WALLETNAME on CONFIG file ..."
fi
questionaire
