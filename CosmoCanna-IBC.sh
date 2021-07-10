#!/bin/bash
# shellcheck disable=SC1091,SC2154
#---------------------------------------------#
#             IBC Transfer Tool               #
#---------------------------------------------#
#              Version: V1.04                 #
#          Donate BitCanna Address:           #
# bcna14dz7zytpenkyyktqvzq2mw7msfyp0y3zg48xqw #
#---------------------------------------------#

########
# EDIT #
MICROTICKWALLETNAME=""
BITCANNAWALLETNAME=""
MTMTOOL="mtm-v2-rc9-linux-x86_64"
MTMVERSION="mtm v2 (mtm-v2-rc9)"
MTMTOOLSHA="0e8eaab9617051bdd8247b0b3f8e27537ca41bb9f7195cb757ad8cf22a7de523"
MTMTOOLLINK="https://microtick.com/releases/testnet/stargate/$MTMTOOL.tar.gz"
DEFAULTAMOUNT="1000000" # 1 000 000 ubcna = 1 BCNA || 1 000 000 utick = 1 TICK
########

. CONFIG

function configvarys(){
info "Set variables to Microtick Tool... Insert Password when asked"
MT_ADDR="$(mtm keys show $MICROTICKWALLETNAME -a)"
MT_RPC="http://seed2.bitcanna.io:26657"
MT_chain="microtick-testnet-rc8-1"
MT_channel="channel-3"
MT_port="transfer"
export MT_ADDR
export MT_RPC
export MT_chain
export MT_channel
export MT_port
info "Set variables to BCNAD... Insert Password when asked"
BCNA_ADDR="$(bcnad keys show $BITCANNAWALLETNAME -a)"
BCNA_RPC="http://seed2.bitcanna.io:16657"
BCNA_chain="bitcanna-testnet-5"
BCNA_channel="channel-0"
BCNA_port="transfer"
GASFLAG="--gas auto --gas-prices 0.09ubcna --gas-adjustment 1.5  --packet-timeout-timestamp 6000000000000"
export BCNA_ADDR
export BCNA_RPC
export BCNA_chain
export BCNA_channel
export BCNA_port
export GASFLAG
}

function getinfo(){
BCNAMoniker=$(curl -s http://localhost:26657/status | grep -Po '"moniker": "\K.*?(?=")')
BCNABALANCE="$(bcnad query bank balances "$BCNA_ADDR" --output json | jq | grep -Po '"amount": "\K.*?(?=")' | tail -1)"
BCNADENOM="$(bcnad query bank balances "$BCNA_ADDR" --output json | jq | grep -Po '"denom": "\K.*?(?=")' | tail -1)"
BCNAIBCBALANCE="$(bcnad query bank balances "$BCNA_ADDR" --output json | jq | grep -Po '"amount": "\K.*?(?=")' | head -1)"
BCNAIBCDENOM="$(bcnad query bank balances "$BCNA_ADDR" --output json | jq | grep -Po '"denom": "\K.*?(?=")' | head -1)"
MTMBALANCE="$(mtm query bank balances "$MT_ADDR" --node $MT_RPC --output json | jq | grep -Po '"amount": "\K.*?(?=")' | tail -1)"
MTMDENOM="$(mtm query bank balances "$MT_ADDR" --node $MT_RPC --output json | jq | grep -Po '"denom": "\K.*?(?=")' | tail -1)"
MTMIBCBALANCE="$(mtm query bank balances "$MT_ADDR" --node $MT_RPC --output json | jq | grep -Po '"amount": "\K.*?(?=")' | head -1)"
MTMIBCDENOM="$(mtm query bank balances "$MT_ADDR" --node $MT_RPC --output json | jq | grep -Po '"denom": "\K.*?(?=")' | head -1)"
}

function setsourceMTaddress(){
while true 
do
info "Put Source Microtick address:"
read -r THESMTADDRESS
THESMTADDRESS=${THESMTADDRESS:-$MT_ADDR}
case "$THESMTADDRESS" in
 micro*) ok "Valid Microtick Address" ; break ;;
 *)  warn "Invalid Microtick Address" ;;
esac
done
}

function setdestMTaddress(){
while true 
do
info "Put Target Microtick address:"
read -r THETMTADDRESS
THETMTADDRESS=${THETMTADDRESS:-$MT_ADDR}
case "$THETMTADDRESS" in
 micro*) ok "Valid Microtick Address" ; break ;;
 *)  warn "Invalid Microtick Address" ;;
esac
done
} 

function setamount(){
while true 
do
info "Put Amount in micro (ubcna/utick):"
read -r THEAMOUNT
THEAMOUNT=${THEAMOUNT:-$DEFAULTAMOUNT}
case $THEAMOUNT in
 ''|*[0-9]*) ok "Valid Amount" ; break ;;
 *) warn "Invalid Amount" ;;
esac
done
}

function setsourceBCNAaddress(){
while true 
do
info "Put Target BCNA address:"
read -r THESBCNAADDRESS
THESBCNAADDRESS=${THESBCNAADDRESS:-$BCNA_ADDR}
case "$THESBCNAADDRESS" in
 bcna*) ok "Valid Bitcanna Address" ; break ;;
 *)  warn "Invalid Bitcanna Address" ;;
esac
done
}

function setdestBCNAaddress(){
while true 
do
info "Put Target BCNA address:"
read -r THETBCNAADDRESS
THETBCNAADDRESS=${THETBCNAADDRESS:-$BCNA_ADDR}
case "$THETBCNAADDRESS" in
 bcna*) ok "Valid Bitcanna Address" ; break ;;
 *)  warn "Invalid Bitcanna Address" ;;
esac
done
}

function mainmenu(){
while true
do
echo -e "                    ${greeny}Bitcanna Wallet${endy}
${bluey}-------------------------------------------------------------------------------------------${endy}
Address: ${greeny}$BCNA_ADDR${endy}
${bluey}-------------------------------------------------------------------------------------------${endy}
BCNA Balance:${endy} ${greeny}$BCNABALANCE $BCNADENOM${endy}
IBC Balance:${endy} ${yellowy}$BCNAIBCBALANCE $BCNAIBCDENOM${endy}

${bluey}===========================================================================================
===========================================================================================${endy}
                    ${yellowy}Microtick Wallet${endy}
${bluey}-------------------------------------------------------------------------------------------${endy}
Address:${endy} $MT_ADDR${endy}
${bluey}-------------------------------------------------------------------------------------------${endy}
TICK Balance:${endy} ${greeny}$MTMBALANCE $MTMDENOM${endy}
IBC Balance:${endy} ${yellowy}$MTMIBCBALANCE $MTMIBCDENOM${endy}
${bluey}-------------------------------------------------------------------------------------------${endy}

${yellowy}Menu${endy}
${bluey}1-${endy} Send ${greeny}ubcna${endy} from Bitcanna address to Microtick address
${bluey}2-${endy} Send ${greeny}ubcna${endy} from Microtick address to Bitcanna address
${bluey}3-${endy} Send ${yellowy}utick${endy} from Microtick address to Bitcanna address
${bluey}4-${endy} Send ${yellowy}utick${endy} from Bitcanna address to Microtick address
${redy}Q- Quit${endy}

Select:${endy}"
read -r choicy
case $choicy in
 1) setdestMTaddress
    setamount
    bcnad tx ibc-transfer transfer "$BCNA_port" "$BCNA_channel" "$THETMTADDRESS" "$THEAMOUNT""$BCNADENOM" --chain-id "$BCNA_chain" --from "$BITCANNAWALLETNAME" -y "$GASFLAG"
    ;;
 2) setdestBCNAaddress
    setamount
    mtm tx ibc-transfer transfer "$MT_port" "$MT_channel" "$THETBCNAADDRESS" "$THEAMOUNT""$MTMIBCDENOM" --chain-id "$MT_chain" --from "$MICROTICKWALLETNAME" -y "$GASFLAG" --node "$MT_RPC"
    ;;
 3) setdestBCNAaddress
    setamount
    mtm tx ibc-transfer transfer "$MT_port" "$MT_channel" "$THETBCNAADDRESS" "$THEAMOUNT""$MTMDENOM" --chain-id "$MT_chain" --from "$MICROTICKWALLETNAME" -y "$GASFLAG" --node "$MT_RPC"
    ;;
 4) setdestMTaddress
    setamount
    bcnad tx ibc-transfer transfer "$BCNA_port" "$BCNA_channel" "$THETMTADDRESS" "$THEAMOUNT""$BCNAIBCDENOM" --chain-id "$BCNA_chain" --from "$BITCANNAWALLETNAME" -y "$GASFLAG"
    ;;
q|Q) ok "Bye Bye Roll One joint for me ;)" && exit 0 ;;
 *) warn "MISSING KEY" && sleep 0.5 ;;
esac
done
}

function installmicrotick(){
info "Getting Microtick Tool"
wget "$MTMTOOLLINK" || erro "Cant download Microtick tool "
if [[ $(sha256sum $MTMTOOL.tar.gz) == "$MTMTOOLSHA" ]]; then 
 ok "Checksum sha256sum  OK"
else
 erro "Checksum sha256sum  FAIL"
fi
tar -xzvf "$MTMTOOL".tar.gz && rm "$MTMTOOL".tar.gz
if [[ $(./mtm version) == "$MTMVERSION" ]] ; then
 sudo mv mtm /usr/local/bin/ || erro "Cannot copy Microtick to /usr/local/bin directory. wrong version"
else
 erro "Wrong Microtick tool Version"
fi
}

function createmicrotickwallet(){
while true
do
info "Choose to get New Microtick WALLET or to RECOVER your WALLET:\n\t J - by *.tar.gz (NOT WORKIN)\n\t G - by *.tar.gz.gpg (GPG Encryption method) (NOT WORKIN)\n\t C - Create New Wallet\n\t E - Exit wallet creation"
read -r recwallet
case "$recwallet" in
 j|J) info "Set Your *.tar.gz file [validator_key.tar.gz]:"
      #read -r keyfile
      #keyfile=${keyfile:-validator_key.tar.gz}
      #info "Detecting $keyfile file..."
      #while [ ! -f "$BCNAUSERHOME"/"$keyfile" ]
      #do		 
      # warn "$keyfile not found...\n Please, put $keyfile on this directory: $BCNAUSERHOME/$keyfile"
      # read -n 1 -s -r -p "$(info "Press any key to continue ... ")"
      #done
      #ok "$keyfile FOUND in $BCNAUSERHOME Directory..."
      #tar xzvf "$BCNAUSERHOME"/"$keyfile" -C "$BCNACONF"
      # break
      ;;
 g|G) info "Set Your *.tar.gz.gpg GPG Encrypted file [validator_key.tar.gz.gpg]:"
      #read -r keyfile
      #keyfile=${keyfile:-validator_key.tar.gz.gpg}
      #info "Detecting $keyfile file..."
      #sleep 0.5
      #while [ ! -f "$BCNAUSERHOME"/"$keyfile" ]
      #do		 
	    # warn "$keyfile not found...\n Please, put $keyfile on this directory: $BCNAUSERHOME/$keyfile"
	    # read -n 1 -s -r -p "$(info "Press any key to continue ... ")"
      #done
      #ok "$keyfile FOUND in $BCNAUSERHOME Directory..."
      #gpg -d "$BCNAUSERHOME"/"$keyfile" | tar xzvf - -C "$BCNACONF"
      #break
      ;;
 c|C) info "Creating New Microtick WALLET" 
      if mtm keys add "$MICROTICKWALLETNAME" |& tee -a "$BCNAUSERHOME"/BCNABACKUP/"$MICROTICKWALLETNAME".moniker.info ; then 
       ok "MICROTICK WALLET NAME Created"
      else
       erro "Impossible Initialize Folders"
      fi
      sleep 2
      warn "TIME TO CLAIM/SEND/ASK FOR COINS"
      sleep 1
      warn "TIME TO CLAIM/SEND/ASK FOR COINS"
      sleep 1
      warn "TIME TO CLAIM/SEND/ASK FOR COINS"
      read -n 1 -s -r -p "$(info "Press any key to continue...")"
      break ;;
  q|Q) warn "Microtick WALLET not created... Continuing.."
       break ;;
 *) warn "Missed key" ;;
esac
done
}

if [ -z "$MICROTICKWALLETNAME" ]; then
 erro "Set MICROTICK WALLET NAME on this script file ..."
fi
if [ -z "$BITCANNAWALLETNAME" ]; then
 erro "Set BITCANNA WALLET NAME on this script file ..."
fi

if command -v mtm; then
 configvarys
 getinfo
 mainmenu
else
 info "Microtick Tool not installed.... Installing it.."
 installmicrotick
 createmicrotickwallet
 configvarys
fi
