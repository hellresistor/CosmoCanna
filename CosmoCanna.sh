#!/bin/bash
# shellcheck disable=SC1091
#-------------------------------------------#
#   A BitCanna-Cosmos-Validator Lazy Tool   #
#-------------------------------------------#
#            Version: V2.00                 #
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
MYMoniker=$(curl http://localhost:26657/status | grep -Po '"moniker": "\K.*?(?=")')
MYVALIDADDRESS=$(curl -s http://localhost:26657/genesis | grep -A13 "$MYMoniker" | tail -n1 | grep -Po '"validator_address": "\K.*?(?=")')
MYDELEGADDRESS=$(curl -s http://localhost:26657/genesis | grep -A12 "$MYMoniker" | tail -n1 | grep -Po '"delegator_address": "\K.*?(?=")')
MYADDRESS=$MYDELEGADDRESS
MYAvaliableBal=$(bcnad query bank balances $MYDELEGADDRESS --output json | jq | grep -Po '"amount": "\K.*?(?=")')
MYCommiBalance=$(bcnad query distribution commission $MYVALIDADDRESS --output json | jq  | grep -Po '"amount": "\K.*?(?=")')
MyRewardBalance=$(bcnad query distribution rewards $MYDELEGADDRESS --output json --chain-id bitcanna-testnet-3 | jq | grep -A4 "total" |  grep -Po '"amount": "\K.*?(?=")')
}

function setsourcevalidator(){
info "Put Source Validator/Operator/Wallet address:"
read -r THESADDRESS
THESADDRESS=${THESADDRESS:-$MYADDRESS}
}

function setamount(){
info "Put Amount (1.000.000ubcna = 1BCNA):"
read -r THEAMOUNT
THEAMOUNT=${THEAMOUNT:-$MYAMOUNT}
}

function setdestvalidator(){
info "Put Target Validator/Operator address:"
read -r THEDADDRESS
THEDADDRESS=${THEDADDRESS:-$MYADDRESS}
}

function menu(){
ok "Welcome To CosmoCanna Lazy-Tool"
sleep 2
while true
do
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
 1) bcnad tx distribution withdraw-all-rewards --from "$MYMONIKER" "$GASFEE" --memo "Withdraw All rewards by CosmoCanna-Lazy tool" --chain-id "$BCNACHAIN" ;;
 2) setdestvalidator
    setamount
    bcnad tx staking delegate "$THEDADDRESS" "$THEAMOUNT"ubcna --from "$MYMONIKER" "$GASFEE" --memo "Delegate by CosmoCanna-Lazy tool" --chain-id "$BCNACHAIN" ;;
 3) setsourcevalidator
    setdestvalidator
    setamount
    bcnad tx staking redelegate "$THESADDRESS" "$THEDADDRESS" "$THEAMOUNT"ubcna --from "$MYMONIKER" "$GASFEE" --memo "Redelegate by CosmoCanna-Lazy tool" --chain-id "$BCNACHAIN" ;;
 4) setsourcevalidator
    setdestvalidator
    setamount
    bcnad tx bank send "$THESADDRESS" "$THEDADDRESS" "$THEAMOUNT"ubcna -y "$GASFEE" --memo "Send Bcna by CosmoCanna-Lazy tool" --chain-id "$BCNACHAIN" ;;
 5)  ;;
 6) setdestvalidator
    setamount
    bcnad tx staking unbond "$THEDADDRESS" "$THEAMOUNT"ubcna --from "$MYMONIKER" "$GASFEE" --memo "Unbond by CosmoCanna-Lazy tool" --chain-id "$BCNACHAIN" ;;
 7) bcnad tx slashing unjail --from "$MYMONIKER" "$GASFEE" --memo "Unjailing by CosmoCanna-Lazy tool" --chain-id "$BCNACHAIN" ;;
 q|Q) ok "Bye Bye Roll One joint for me ;)" && exit 0 ;;
 *) warn "MISSING KEY"
esac
done
}

###############
###  Start  ###
###############
checkservicestatus
getwalletinfo
menu
