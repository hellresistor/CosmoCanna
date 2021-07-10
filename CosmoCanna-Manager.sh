#!/bin/bash
# shellcheck disable=SC1091
#-------------------------------------------#
#   A BitCanna-Cosmos-Validator Lazy Tool   #
#-------------------------------------------#
#            Version: V2.30                 #
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
MYWALLETNAME="$MYMoniker"
MYVALIDADDRESS=$(bcnad query staking validators --output json | jq | grep -B10 "$MYMoniker" | head -n1 | grep -Po '"operator_address": "\K.*?(?=")')
MYDELEGADDRESS=$(bcnad keys show "$MYWALLETNAME" -a)
MYADDRESS=$MYDELEGADDRESS
MYAvaliableBal=$(bcnad query bank balances "$MYDELEGADDRESS" --output json | jq | grep -Po '"amount": "\K.*?(?=")')
MYCommiBalance=$(bcnad query distribution commission "$MYVALIDADDRESS" --output json | jq  | grep -Po '"amount": "\K.*?(?=")')
MyRewardBalance=$(bcnad query distribution rewards "$MYDELEGADDRESS" --output json --chain-id "$BCNACHAINID" | jq | grep -A4 "total" |  grep -Po '"amount": "\K.*?(?=")')
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
5- Edit Validator
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
 5) info "Set your Website"
    read -r MYWEBSITE
    info "Set your PGP Keybase key"
    read -r MYPGPKEY
    info "Set Some Details"
    read -r MYDETAILS
    bcnad tx staking edit-validator --moniker \""$MYMoniker"\" --website \""$MYWEBSITE"\" --identity \""$MYPGPKEY"\" --details \""$MYDETAILS"\" --from \""$MYWALLETNAME"\" --memo "Edit Validator by CosmoCanna-Lazy tool" --chain-id "$BCNACHAINID" "$GASFEE"
    ;;
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
