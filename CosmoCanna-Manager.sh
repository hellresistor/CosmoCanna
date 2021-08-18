#!/bin/bash
#-------------------------------------------#
#   A BitCanna-Cosmos-Validator Lazy Tool   #
#-------------------------------------------#
#            Version: V3.00                 #
#        Donate BitCanna Address:           #
#--> B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv <-- #
#-------------------------------------------#

. CONFIG

function getwalletinfo(){
MYMoniker=$(curl -s http://localhost:26657/status | grep -Po '"moniker": "\K.*?(?=")')
BCNACHAINID=("bitcanna-testnet-6")
GASFEE=('--gas auto --gas-adjustment 1.5 --gas-prices 0.01ubcna')
MYWALLETNAME="${MYMoniker}"
MYVALIDADDRESS=$(bcnad query staking validators --output json | jq | grep -B10 "$MYMoniker" | head -n1 | grep -Po '"operator_address": "\K.*?(?=")')

if [ -z "$KEYPWD" ] ; then
 info "Put keyring wallet password:"
 read -s -p KEYPWD
 export KEYPWD
fi

if MYDELEGADDRESS=$(echo -e "${KEYPWD}" | bcnad keys show "$MYWALLETNAME" -a) ; then
 MYADDRESS="$MYDELEGADDRESS"
 export MYADDRESS
else
 erro "Check MYWALLETNAME variable and put your walletname"
fi
MYAvaliableBal=$(bcnad query bank balances "$MYDELEGADDRESS" --output json | jq | grep -Po '"amount": "\K.*?(?=")' | tail -1)
MYCommiBalance=$(bcnad query distribution commission "$MYVALIDADDRESS" --output json | jq  | grep -Po '"amount": "\K.*?(?=")')
MyRewardBalance=$(bcnad query distribution rewards "$MYDELEGADDRESS" --output json --chain-id "$BCNACHAINID" | jq | grep -A4 "total" |  grep -Po '"amount": "\K.*?(?=")')
}

function checkservicestatus(){
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
}

function setsourcewaddress(){
while true 
do
info "Put Source Wallet address:"
read -r THESWADDRESS
THESWADDRESS=${THESWADDRESS:-$MYADDRESS}
case "$THESWADDRESS" in
 bcna*) ok "Valid Bitcanna Address" ; break ;;
 *)  warn "Invalid Bitcanna Address" ;;
esac
done
}

function setdestwaddress(){
while true 
do
info "Put Target Wallet address:"
read -r THEDWADDRESS
THEDWADDRESS=${THEDWADDRESS:-$MYADDRESS}
case "$THEDWADDRESS" in
 bcna*) ok "Valid Bitcanna Address" ; break ;;
 *)  warn "Invalid Bitcanna Address" ;;
esac
done
}

function setamount(){
while true 
do
info "Put Amount (1.000.000ubcna = 1BCNA):"
read -r THEAMOUNT
THEAMOUNT=${THEAMOUNT:-$MYAMOUNT}
case $THEAMOUNT in
 ''|*[0-9]*) ok "Valid Amount" ; break ;;
 *) warn "Invalid Amount" ;;
esac
done
}

function setsourceoaddress(){
while true 
do
info "Put Target Validator/Operator address:"
read -r THESOADDRESS
THESOADDRESS=${THESOADDRESS:-$MYVALIDADDRESS}
case "$THESOADDRESS" in
 bcnavaloper*) ok "Valid Bitcanna Address" ; break ;;
 *)  warn "Invalid Bitcanna Address" ;;
esac
done
}

function setdestoaddress(){
while true 
do
info "Put Target Validator/Operator address:"
read -r THEDOADDRESS
THEDOADDRESS=${THEDOADDRESS:-$MYVALIDADDRESS}
case "$THEDOADDRESS" in
 bcnavaloper*) ok "Valid Bitcanna Address" ; break ;;
 *)  warn "Invalid Bitcanna Address" ;;
esac
done
}

function menu(){
ok "Welcome To CosmoCanna Lazy-Tool by hellresistor"
sleep 0.5
while true
do
getwalletinfo
echo -e "${bluey}===========================================================================================${endy}

                                    ${greeny}Bitcanna Manager${endy}

${bluey}===========================================================================================${endy}

My Moniker:${endy} ${greeny}$MYMoniker${endy}
My Validator Address:${endy} ${greeny}$MYVALIDADDRESS${endy}
My Wallet Address:${endy} ${greeny}$MYDELEGADDRESS${endy}
BCNA Balance:${endy} ${greeny}$MYAvaliableBal ubcna${endy}
Avaliable Bal.:${endy} ${greeny}$MYAvaliableBal ubcna${endy}
Rewards Bal.:${endy} ${greeny}$MyRewardBalance ubcna${endy}
Comission Bal.:${endy} ${greeny}$MYCommiBalance ubcna${endy}

${bluey}===========================================================================================${endy}

${yellowy}Menu${endy}
${bluey}1-${endy} Withdraw All Rewards
${bluey}2-${endy} Delegate
${bluey}3-${endy} Redelegate
${bluey}4-${endy} Send Coins
${bluey}5-${endy} Edit Validator
${bluey}6-${endy} Unbond
${bluey}7-${endy} Unjail Validator

${redy}Q- Quit${endy}

Select:${endy}"
read -r choicy
case $choicy in
 1) bcnad tx distribution withdraw-all-rewards --from ${MYMoniker} --chain-id ${BCNACHAINID} --memo "Withdraw All rewards by CosmoCannaLazy tool" ${GASFEE} ;;
 2) setdestoaddress
    setamount
    echo -e "${KEYPWD}" | bcnad tx staking delegate "$THEDOADDRESS" "$THEAMOUNT"ubcna --from "$MYMoniker" ${GASFEE} --memo "Delegate by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" -y ;;
 3) setsourceoaddress
    setdestoaddress
    setamount
    echo -e "${KEYPWD}" | bcnad tx staking redelegate "$THESOADDRESS" "$THEDOADDRESS" "$THEAMOUNT"ubcna --from "$MYMoniker" ${GASFEE} --memo "Redelegate by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" -y ;;
 4) setsourcewaddress
    setdestwaddress
    setamount
    echo -e "${KEYPWD}" | bcnad tx bank send "$THESWADDRESS" "$THEDWADDRESS" "$THEAMOUNT"ubcna ${GASFEE} --memo "Send Bcna by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" -y ;;
 5) info "Set your Website"
    read -r MYWEBSITE
    info "Set your PGP Keybase key"
    read -r MYPGPKEY
    info "Set Some Details"
    read -r MYDETAILS
    echo -e "${KEYPWD}" | bcnad tx staking edit-validator --moniker "$MYMoniker" --website \"$MYWEBSITE\" --identity "$MYPGPKEY" --details \"$MYDETAILS\" --from \"$MYWALLETNAME\" ${GASFEE} --memo "Edit Validator by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" -y
    ;;
 6) setdestwaddress
    setamount
    echo -e "${KEYPWD}" | bcnad tx staking unbond "$THEDWADDRESS" "$THEAMOUNT"ubcna --from "$MYMoniker" ${GASFEE} --memo "Unbond by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" -y ;;
 7) echo -e "${KEYPWD}" | bcnad tx slashing unjail --from "$MYMoniker" ${GASFEE} --memo "Unjailing by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" -y ;;
 q|Q) ok "Bye Bye Roll One joint for me ;)" && exit 0 ;;
 *) warn "MISSING KEY" && sleep 0.5;;
esac
done
}

###############
###  Start  ###
###############
checkservicestatus
menu
