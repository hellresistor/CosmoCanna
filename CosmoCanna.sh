#!/bin/bash
# shellcheck disable=SC1091
#-------------------------------------------#
#   A BitCanna-Cosmos-Validator Lazy Tool   #
#-------------------------------------------#
#            Version: V2.10                 #
#        Donate BitCanna Address:           #
#--> B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv <-- #
#-------------------------------------------#
. CONFIG

function checkservicestatus(){
info "Check $BCNAD.service Running"
if sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
 ok "$BCNAD Is Running"
elif ! sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
 erro "$BCNAD is Stopped. Run bcnad"
else
 erro "Something wrong with $BCNAD.service"
fi
}

function getwalletinfo(){
BCNACHAINID="bitcanna-testnet-5"
GASFEE="--gas-adjustment 1.5 --gas auto --gas-prices 0.01ubcna"
MYMoniker=$(curl http://localhost:26657/status | grep -Po '"moniker": "\K.*?(?=")')
MYVALIDADDRESS=$(curl -s http://localhost:26657/genesis | grep -A13 "$MYMoniker" | tail -n1 | grep -Po '"validator_address": "\K.*?(?=")')
MYDELEGADDRESS=$(curl -s http://localhost:26657/genesis | grep -A12 "$MYMoniker" | tail -n1 | grep -Po '"delegator_address": "\K.*?(?=")')
MYADDRESS=$MYDELEGADDRESS
MYAvaliableBal=$(bcnad query bank balances "$MYDELEGADDRESS" --output json | jq | grep -Po '"amount": "\K.*?(?=")')
MYCommiBalance=$(bcnad query distribution commission "$MYVALIDADDRESS" --output json | jq  | grep -Po '"amount": "\K.*?(?=")')
MyRewardBalance=$(bcnad query distribution rewards "$MYDELEGADDRESS" --output json --chain-id "$BCNACHAINID" | jq | grep -A4 "total" |  grep -Po '"amount": "\K.*?(?=")')
}

function setsourcewaddress(){
info "Put Source Wallet address:"
read -r THESWADDRESS
THESWADDRESS=${THESWADDRESS:-$MYADDRESS}
}

function setdestwaddress(){
info "Put Target Wallet address:"
read -r THEDWADDRESS
THEDWADDRESS=${THEDWADDRESS:-$MYADDRESS}
}

function setamount(){
info "Put Amount (1.000.000ubcna = 1BCNA):"
read -r THEAMOUNT
THEAMOUNT=${THEAMOUNT:-$MYAMOUNT}
}

function setsourceoaddress(){
info "Put Target Validator/Operator address:"
read -r THESOADDRESS
THESOADDRESS=${THESOADDRESS:-$MYVALIDADDRESS}
}

function setdestoaddress(){
info "Put Target Validator/Operator address:"
read -r THEDOADDRESS
THEDOADDRESS=${THEDOADDRESS:-$MYVALIDADDRESS}
}

function menu(){
ok "Welcome To CosmoCanna Lazy-Tool by hellresistor"
sleep 2
while true
do
getwalletinfo
info "
My Moniker: $MYMoniker
My Validator Address: $MYVALIDADDRESS
------------------------------------------------------------------------------
My Wallet Address: $MYDELEGADDRESS
Avaliable Bal.: $MYAvaliableBal ubcna
Rewards Bal.: $MyRewardBalance ubcna
Comission Bal.: $MYCommiBalance ubcna
------------------------------------------------------------------------------
Menu:
1- Withdraw All Rewards
2- Delegate
3- Redelegate
4- Send Coins
5-
6- Unbond
7- Unjail Validator

Q- Bye Bye
 
Choice:"
read -r choicy
case $choicy in
 1) bcnad tx distribution withdraw-all-rewards --from "$MYMoniker" "$GASFEE" --memo "Withdraw All rewards by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" ;;
 2) setdestoaddress
    setamount
    bcnad tx staking delegate "$THEDOADDRESS" "$THEAMOUNT"ubcna --from "$MYMoniker" "$GASFEE" --memo "Delegate by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" ;;
 3) setsourceoaddress
    setdestoaddress
    setamount
    bcnad tx staking redelegate "$THESOADDRESS" "$THEDOADDRESS" "$THEAMOUNT"ubcna --from "$MYMoniker" "$GASFEE" --memo "Redelegate by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" ;;
 4) setsourcewaddress
    setdestwaddress
    setamount
    bcnad tx bank send "$THESWADDRESS" "$THEDWADDRESS" "$THEAMOUNT"ubcna -y "$GASFEE" --memo "Send Bcna by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" ;;
 5)  ;;
 6) setdestwaddress
    setamount
    bcnad tx staking unbond "$THEDWADDRESS" "$THEAMOUNT"ubcna --from "$MYMoniker" "$GASFEE" --memo "Unbond by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" ;;
 7) bcnad tx slashing unjail --from "$MYMoniker" "$GASFEE" --memo "Unjailing by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" ;;
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
