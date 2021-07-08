#!/bin/bash
# shellcheck disable=SC1091
#---------------------------------------------------#
#  A BitCanna-Cosmos Community Installation Script  #
#                                                   #   
#---------------------------------------------------#
#---------------------------------------------------#
#                  Version: V3.05                   #
#             Donate BitCanna Address:              #
#    --> B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv <--     #
#---------------------------------------------------#

########
# EDIT #
MONIKER="" ## Set Your Moniker## 
WALLETNAME="${MONIKER}WALLET" ## Set Your Name Wallet
CHAINID="bitcanna-testnet-5"  ## Set correct chain

. CONFIG

function varys(){
BCNACOSMOSREP="testnet-bcna-cosmos"
BCNACOSMOSLINK=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep 'browser_download_url' | cut -d\" -f4 | head -1)
GENESISLINK="https://raw.githubusercontent.com/BitCannaGlobal/$BCNACOSMOSREP/main/instructions/stage5/genesis.json"
#PERSISTPEERS="d6aa4c9f3ccecb0cc52109a95962b4618d69dd3f@seed1.bitcanna.io:26656,41d373d03f93a3dc883ba4c1b9b7a781ead53d76@seed2.bitcanna.io:16656"
#SEEDS="d6aa4c9f3ccecb0cc52109a95962b4618d69dd3f@seed1.bitcanna.io:26656,41d373d03f93a3dc883ba4c1b9b7a781ead53d76@seed2.bitcanna.io:16656,8e241ba2e8db2e83bb5d80473b4fd4d901043dda@178.128.247.173:26652"
PERSISTPEERS="acc177d5af9fad3064c1831bba41718d5f0ef2ce@167.71.0.53:26656,dcdc83e240eb046faabef62e4daf1cfcecfa93a2@159.65.198.245:26656"
SEEDS="d6aa4c9f3ccecb0cc52109a95962b4618d69dd3f@seed1.bitcanna.io:26656,41d373d03f93a3dc883ba4c1b9b7a781ead53d76@seed2.bitcanna.io:16656,8e241ba2e8db2e83bb5d80473b4fd4d901043dda@178.128.247.173:26656"
BCNAUSERHOME="$HOME"
BCNADIR="$BCNAUSERHOME/.bcna"
BCNACONF="$BCNADIR/config"
BCNADATA="$BCNADIR/data"
BCNAD="bcnad"
BCNAPORT="26656"
SCRPTVER="V3.05"
DONATE="B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv"
DATENOW=$(date +"%Y%m%d%H%M%S")
VPSIP=$(curl -s ifconfig.me)
}

function bitcannacosmosdownload(){
info "Lets Download and Extract the Bitcanna-Cosmos wallet from GitHub"
if [[ ! -f "$BCNAUSERHOME"/BCNABACKUP ]]; then
 mkdir -p "$BCNAUSERHOME"/BCNABACKUP
fi
if [[ -d "$BCNADIR" ]]; then 
 [ "$(cp -f -r --preserve "$BCNADIR" "$BCNAUSERHOME"/BCNABACKUP/.bcna."${DATENOW}")" ] && ok "Old $BCNADIR Backed UP"
else
 warn "Not Exist a Old $BCNADIR to be backeuped"
fi
if wget "$BCNACOSMOSLINK" -P /tmp > /dev/null 2>&1 ; then 
 sudo chmod +x /tmp/"$BCNAD"
 /tmp/"$BCNAD" version || erro "Cannot check bcna version"
 sleep 2
 ok "Latest Bitcanna-Cosmos Downloaded"
else
 erro "Latest Bitcanna-Cosmos Cannot be downloaded"
fi
if mv "$BCNACONF"/genesis.json "$BCNAUSERHOME"/BCNABACKUP/genesis.json.bck > /dev/null 2>&1 ; then
 ok "Old genesis.json saved on $BCNAUSERHOME/BCNABACKUP/genesis.json.bck"
else 
 warn "Old genesis.json file not exist. Not backuped"
fi
if wget "$GENESISLINK" -P /tmp > /dev/null 2>&1 ; then
 ok "Genesis file downloaded"
else 
 erro "Download genesis.json failed"
fi
if sudo cp -p /tmp/"$BCNAD" /usr/local/bin/"$BCNAD" > /dev/null 2>&1 && sudo chmod +x /usr/local/bin/"$BCNAD" > /dev/null 2>&1 ; then 
 ok "Binaries in place /usr/local/bin/$BCNAD"
else
 warn "Cannot set binary file $BCNAD on dir /usr/bin"
fi
info "Preparing Backups Info skel"

cat <<EOF >> "$BCNAUSERHOME"/BCNABACKUP/walletinfo.txt
Bitcanna-Cosmos Node Info Generated in $DATENOW

Host:	$HOSTNAME
IP:	$VPSIP
User:	$USER
EOF
}

function checkin(){
intro
info "Welcome!\nChoose:\n(I)nstall , (U)pdate , (R)emove :"
read -r choix
if [ "$choix" == "i" ] || [ "$choix" == "I" ]; then 
 info "New and Clean installation of Bitcanna-Cosmos wallet"
 if [[ ! -a $(find "/usr/local/bin" -name "$BCNAD") ]] ; then
  bitcannacosmosdownload
  SettingConnection
  StageOne
  backup
  cleaner
 else
  erro "Detected Bitcanna-Cosmos wallet already installed. Run Update or Remove"
 fi
elif [ "$choix" == "u" ] || [ "$choix" == "U" ]; then 
 info "Updating to last version of Bitcanna-Cosmos wallet"
 if [[ -a $(find "/usr/local/bin" -name "$BCNAD") ]] ; then
  info "Old Bitcanna-Cosmos version found"
  if sudo systemctl stop "$BCNAD".service > /dev/null 2>&1 ; then
   ok "Bitcanna Wallet Started"
   else 
    erro "Some Error on Starting Wallet. Check it Manually"
   fi
  sleep 5
  sudo rm -f /usr/local/bin/"$BCNAD" || erro "Unable to Delete: /usr/local/bin/$BCNAD"
  bitcannacosmosdownload
  cleaner
  ok "Bitcanna-Cosmos wallet Updated to LAST version"
  if sudo systemctl start "$BCNAD".service > /dev/null 2>&1 ; then
   ok "Bitcanna Wallet Started"
   sync
  else 
   erro "Some Error on Starting Wallet. Check it Manually"
  fi
 else
  erro "Can not find Bitcanna-Cosmos wallet. Install It First"
 fi
elif [ "$choix" == "r" ] || [ "$choix" == "R" ]; then 
 if [[ -a $(find "/usr/local/bin" -name "$BCNAD") ]] ; then
  info "Old Bitcanna-Cosmos version found"
  info "FULL REMOVING Bitcanna-Cosmos wallet"
  if sudo systemctl stop "$BCNAD".service > /dev/null 2>&1 ; then
   ok "Bitcanna Wallet Stopped"
  else 
   warn "Some Error on Stopping Wallet. Check it Manually"
  fi
  sleep 5
   cleaner
  sudo systemctl disable "$BCNAD".service
  sudo rm -f /usr/local/bin/"$BCNAD" > /dev/null 2>&1 || warn "Cannot Delete /usr/local/bin/$BCNAD"
  sudo rm /lib/systemd/system/"$BCNAD".service || warn "Cannot remove /lib/systemd/system/$BCNAD.service"
  if [[ ! -f "$BCNAUSERHOME"/BCNABACKUP ]]; then
   mkdir -p "$BCNAUSERHOME"/BCNABACKUP
  fi
  cp -f -r --preserve "$BCNADIR" "$BCNAUSERHOME"/BCNABACKUP/.bcna."${DATENOW}" > /dev/null 2>&1 || erro "Cannot Copy $BCNADIR"
  sudo rm -R "$BCNADIR" > /dev/null 2>&1 || warn "Cannot Delete $BCNADIR"
  ok "Bitcanna-Cosmos wallet was FULLY Removed"
 else
   erro "Bitcanna-Cosmos wallet not exist\nInstall it\n"
 fi
else
 erro "Choose a correct option"
fi
}

function cleaner(){
info "Cleaning...."
sudo rm -r /tmp/*  > /dev/null 2>&1 && ok "/tmp folder cleaned"
#history -cw
}

function syncr(){
info "Syncronizing with Blockchain"
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
}

function SettingConnection(){
while true
do
info "Choose method to recover your wallet:\n\t K - by PrivKey file\n\t S - by Seed\n\t C - Create New Wallet"
read -r recwallet
case "$recwallet" in
 k|K) info "Set Your *.key file [keyfile_wallet_resources.key]:"
      read -r keyfile
      keyfile=${keyfile:-keyfile_wallet_resources.key}
      info "Detecting $keyfile file..."
      sleep 0.5
      while [ ! -f "$BCNAUSERHOME"/"$keyfile" ]
      do		 
       warn "$keyfile not found...\n Please, put $keyfile on this directory: $BCNAUSERHOME/$keyfile"
       read -n 1 -s -r -p "$(info "Press any key to continue ... ")"
      done
      ok "$keyfile FOUND in $BCNAUSERHOME Directory..."
      "$BCNAD" keys import "$WALLETNAME" "$keyfile"
      sleep 0.5
      break ;;
 s|S) info "Put your Wallet Name to Recovery :"
      read -r WALLETNAME
      "$BCNAD" keys add "$WALLETNAME" --recover
      break ;;
 c|C) info "Creating New Wallet"
      WALLETPASS="dummy1"
      WALLETPASSS="dummy2"
      while [[ "$WALLETPASS" != "$WALLETPASSS" ]]
      do
       info "Set PassPhrase: " && read -rsp "" WALLETPASS
       while [[ "${#WALLETPASS}" -lt 8 ]]
       do
        info "Set PassPhrase (+8 chars): " && read -rsp "" WALLETPASS
       done
       warn "Repeat PassPhrase: " && read -rsp "" WALLETPASSS
      done
      if echo -e "${WALLETPASS}\\n${WALLETPASSS}" | "$BCNAD" keys add \""$WALLETNAME"\" |& tee -a "$BCNAUSERHOME"/BCNABACKUP/"$WALLETNAME".walletinfo; then 
       ok "Wallet: $WALLETNAME created succefully"
       if [[ -f "$BCNAUSERHOME"/BCNABACKUP/"$WALLETNAME".walletinfo ]] ; then
        echo "Passphrase : $WALLETPASS" >> "$BCNAUSERHOME"/BCNABACKUP/"$WALLETNAME".walletinfo
        MYWALLETADDR=$(sed -n -e 's/.*address: //p' "$BCNAUSERHOME"/BCNABACKUP/"$WALLETNAME".walletinfo)
       else
        erro "$BCNAUSERHOME/BCNABACKUP/$WALLETNAME.walletinfo NOT FOUND"
       fi
      else 
       erro "Wallet: $WALLETNAME NOT created"
      fi 
      break ;;
    *) warn "Missed key" ;;
esac
done
while true
do
info "Choose to get New MONIKER or to RECOVER your MONIKER:\n\t J - by *.tar.gz\n\t G - by *.tar.gz.gpg (GPG Encryption method)\n\t C - Create New Moniker"
read -r recvalidator
case "$recvalidator" in
 j|J) info "Set Your *.tar.gz file [validator_key.tar.gz]:"
      read -r keyfile
      keyfile=${keyfile:-validator_key.tar.gz}
      info "Detecting $keyfile file..."
      while [ ! -f "$BCNAUSERHOME"/"$keyfile" ]
      do		 
       warn "$keyfile not found...\n Please, put $keyfile on this directory: $BCNAUSERHOME/$keyfile"
       read -n 1 -s -r -p "$(info "Press any key to continue ... ")"
      done
      ok "$keyfile FOUND in $BCNAUSERHOME Directory..."
      tar xzvf "$BCNAUSERHOME"/"$keyfile" -C "$BCNACONF"
      break ;;
 g|G) info "Set Your *.tar.gz.gpg GPG Encrypted file [validator_key.tar.gz.gpg]:"
      read -r keyfile
      keyfile=${keyfile:-validator_key.tar.gz.gpg}
      info "Detecting $keyfile file..."
      sleep 0.5
      while [ ! -f "$BCNAUSERHOME"/"$keyfile" ]
      do		 
	warn "$keyfile not found...\n Please, put $keyfile on this directory: $BCNAUSERHOME/$keyfile"
	read -n 1 -s -r -p "$(info "Press any key to continue ... ")"
      done
      ok "$keyfile FOUND in $BCNAUSERHOME Directory..."
      gpg -d "$BCNAUSERHOME"/"$keyfile" | tar xzvf - -C "$BCNACONF"
      break ;;
 c|C) info "Creating New MONIKER" 
      if "$BCNAD" init "$MONIKER" --chain-id "$CHAINID" |& tee -a "$BCNAUSERHOME"/BCNABACKUP/"$MONIKER".moniker.info ; then 
	ok "Folders Initialized"
      else
	erro "Impossible Initialize Folders"
      fi
      break ;;
 *) warn "Missed key" ;;
esac
done

if cp /tmp/genesis.json "$BCNACONF"/genesis.json > /dev/null 2>&1 ; then
 ok "genesis.json file moved to $BCNAUSERHOME/$BCNACONF/genesis.json"
else 
 erro "genesis.json file NOT moved to $BCNAUSERHOME/$BCNACONF/genesis.json"
fi
sed -E -i "s/seeds = \".*\"/seeds = \"$SEEDS\"/" "$BCNACONF"/config.toml || erro "Cannot set seeds on config.toml file"
sed -E -i "s/persistent_peers = \".*\"/persistent_peers = \"$PERSISTPEERS\"/" "$BCNACONF"/config.toml || erro "Cannot set persistpeers on config.toml file"
sed -E -i "s/minimum-gas-prices = \".*\"/minimum-gas-prices = \"0.01ubcna\"/" "$BCNACONF"/app.toml || erro "Cannot set minimum-gas on app.toml file"

if sudo systemctl is-active ufw > /dev/null; then
 ok "ufw Active"
else
 info "Enabling ufw"
 if sudo ufw enable ; then
  ok "ufw Active"
 else 
  warn "Firewall not enabled. Do a manual check."
 fi
fi
if sudo ufw allow "$BCNAPORT" ; then
 ok "Firewall configured on port: $BCNAPORT"
else 
 warn "Firewall not configured. Do a manual check."
 warn "Execute: sudo ufw allow $BCNAPORT" && sleep 1
fi

if [[ -f "/lib/systemd/system/$BCNAD.service" ]] ; then
 warn "$BCNAD.service Exist. Not created new one"
 if sudo systemctl start "$BCNAD".service ; then 
  ok "Bitcanna-Cosmos Service Started"
 else 
  erro "Problem Starting Bitcanna-Cosmos Service"
 fi
else
 echo "[Unit]
Description=BitCanna Node
After=network-online.target
[Service]
User=${USER}
ExecStart=$(command -v "$BCNAD") start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > /tmp/"$BCNAD".service
 if sudo mv /tmp/"$BCNAD".service /lib/systemd/system/ && sudo systemctl enable "$BCNAD".service ; then
  if sudo systemctl start "$BCNAD".service ; then 
   ok "Bitcanna-Cosmos Service Started"
  else 
   erro "Problem Starting Bitcanna-Cosmos Service"
  fi
 else 
  erro "Problem setting Bitcanna-Cosmos Service"
 fi
fi
sleep 5
syncr
info "Lets Check Syncronization again"
sleep 2
syncr
sleep 2
warn "TIME TO CLAIM/SEND/ASK FOR COINS"
sleep 1
warn "TIME TO CLAIM/SEND/ASK FOR COINS"
sleep 1
warn "TIME TO CLAIM/SEND/ASK FOR COINS"
read -n 1 -s -r -p "$(info "Press any key to continue...")"
}

function backup(){
info "Backup Validator keys"
cd "$BCNACONF" || warn "Cannot access to .config file"
if tar -czf "$BCNAUSERHOME"/BCNABACKUP/validator_key.tar.gz ./*_key.json  ; then
 ok "*_key.json files Compressed"
 if gpg -o "$BCNAUSERHOME"/BCNABACKUP/validator_key.tar.gz.gpg -ca "$BCNAUSERHOME"/BCNABACKUP/validator_key.tar.gz ; then
  rm "$BCNAUSERHOME"/BCNABACKUP/validator_key.tar.gz
  ok "Keys saved and encrypted on $BCNAUSERHOME/BCNABACKUP/validator_key.tar.gz.gpg"
 else
  warn "FAILED Backing Up the KEYS! DO IT MANUALLY" 
 fi
else
 warn "*_key.json files NOT Compressed"
fi
cd - || warn "Cannot access to .config file"
info "Backup Wallet Keys..."
if "$BCNAD" keys export "$WALLETNAME" ; then
 ok "$WALLETNAME wallet Keys exported"
else 
 warn "Unable export Keys from wallet $WALLETNAME. Do it manually"
fi
}

function StageOne(){
while true
do 
info "You Want Set up the Validator? (Y|n)"
read -r choicsettingadvance
case "$choicsettingadvance" in
 y|Y) validator && break;;
 n|N) warn "Validator NOT set" && break;;
 *) warn "Wrong key" ;;
esac 
done
while true
do 
info "You Want Set up the Prometheus Analytics? (Y|n)"
read -r choicsettingadvance
case "$choicsettingadvance" in
 y|Y) prometheus && break ;;
 n|N) warn "Prometheus NOT set" && break ;;
 *) warn "Wrong key" ;;
esac 
done
while true
do
info " You want delegate ?! (Y|n)"
read -r choicdeleg
case "$choicdeleg" in
 y|Y) delegatecoins && break ;;
 n|N) warn "NOT Delegating coins" && break ;;
 *) warn "Wrong key" ;;
esac 
done
}

function validator(){
while [[ "$amountdelegate" != ^[0-9]+$ ]]; do
 info "How much ubcna you want delegate to validator? (1000000ubcna = 1 BCNA): [1000000]:"
 read -r amountdelegate
 amountdelegate=${amountdelegate:-1000000}
 if [[ "$amountdelegate" =~ ^[0-9]+$ ]]; then
  ok "Valid amount: $amountdelegate ubcna"
 else
  warn "Just Numbers Valid"
 fi
done
if "$BCNAD" tx staking create-validator \
--amount "$amountdelegate"ubcna \
--commission-max-change-rate 0.10 \
--commission-max-rate 0.2 \
--commission-rate 0.1 \
--from \""$WALLETNAME"\" \
--min-self-delegation 1 \
--moniker \""$MONIKER"\" \
--pubkey "$($BCNAD tendermint show-validator)" \
--chain-id "$CHAINID" \
--gas auto \
--gas-adjustment 1.5 \
--gas-prices 0.01ubcna >> "$BCNAUSERHOME"/BCNABACKUP/createvalidator.extract ; then
ok "Validator Created"
else
 warn "Some problem creating Validator. Check it Manually"
fi

if "$BCNAD" query staking validators --output json | jq >> "$BCNAUSERHOME"/BCNABACKUP/querystakevalidator.extract ; then
 ok "Query staking validators saved on $BCNAUSERHOME/BCNABACKUP/querystakevalidator.extract"
else
 warn "Cannot Query staking validators. Do it Manually"
fi
}

function prometheus() {
sed -i "s/prometheus = \".*\"/prometheus = true/" "$BCNACONF"/config.toml || erro "Cannot Enable Prometheus"
sed -i "s/prometheus_listen_addr = \".*\"/prometheus_listen_addr = \"0.0.0.0:26660\"/" "$BCNACONF"/config.toml || erro "Cannot Listen Address Prometheus"
sudo service "$BCNAD" restart || warn "Unable Restart Bitcanna by service. Check it Manually."
if sudo ufw allow from 167.172.43.16 proto tcp to any port 26660 ; then
 ok "UFW rule added to Prometheus analytics"
else
 erro "UFW rule NOT added to Prometheus analytics"
fi
}

function delegatecoins(){
info " Check my friend @atmon3r repository on GitHub and get the code"
info " https://github.com/atmoner/cosmos-tool.git"
info " Use, abuse and improove :)"
read -n 1 -s -r -p "$(info "Press any key to continue...")"
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
varys
if bash CheckSystem.sh ; then
 true
else
 erro "Failing Check System"
fi
if bash CheckRequisites.sh ; then
 true
else
 erro "Failing Check Requirements"
fi
checkin
concl
exit 0
