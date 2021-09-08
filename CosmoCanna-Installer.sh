##!/bin/bash
# shellcheck disable=SC1091,SC2034
#---------------------------------------------------#
#  A BitCanna-Cosmos Community Installation Script  #
#               bcnad + cosmovisor                  #   
#---------------------------------------------------#
#---------------------------------------------------#
#                  Version: V6.09                   #
#             Donate BitCanna Address:              #
#    --> B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv <--     #
#---------------------------------------------------#

########
# EDIT #
MONIKER="" ## Set Your Moniker## 
WALLETNAME="${MONIKER}Wallet" ## Set Your Name Wallet
CHAINID="bitcanna-testnet-7"  ## Set correct chain
BCNACOSMOSREP="bcna"
GENESISLINK="https://raw.githubusercontent.com/BitCannaGlobal/testnet-bcna-cosmos/main/instructions/pre-swap/genesis.json"

. CONFIG

function varys(){
BCNADLINK=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep 'browser_download_url' | cut -d\" -f4 | head -1)
BCNADLINKSHA=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep "binary sha256sum:" | cut -d\` -f4)
COSMOVISORLINK=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep 'browser_download_url' | cut -d\" -f4 | tail -1)
COSMOVISORLINKSHA=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep "binary sha256sum:" | cut -d\` -f8)
VERSIONNEW=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep "tag_name" | cut -d\" -f4 | head -1)
VERSIONOLD=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases" | grep "tag_name" | cut -d\" -f4 | head -2 | tail -1)
SEEDS="d6aa4c9f3ccecb0cc52109a95962b4618d69dd3f@seed1.bitcanna.io:26656,23671067d0fd40aec523290585c7d8e91034a771@seed2.bitcanna.io:16656"
BCNAUSERHOME="$HOME"
BCNADIR="$BCNAUSERHOME/.bcna"
BCNACONF="$BCNADIR/config"
BCNADATA="$BCNADIR/data"
BCNAD="bcnad"
COSMOV="cosmovisor"
BCNAPORT="26656"
SCRPTVER="V6.09"
DONATE="B73RRFVtndfPRNSgSQg34yqz4e9eWyKRSv"
DATENOW=$(date +"%Y%m%d%H%M%S")
VPSIP=$(curl -s ifconfig.me)
}

function bitcannadownload(){
info "Lets Download and Extract the Bitcanna-Cosmos wallet from GitHub"
if [[ ! -f "$BCNAUSERHOME"/BCNABACKUP ]]; then
 mkdir -p "$BCNAUSERHOME"/BCNABACKUP
fi
if [[ -d "$BCNADIR" ]]; then 
 [ "$(cp -f -r --preserve "$BCNADIR" "$BCNAUSERHOME"/BCNABACKUP/.bcna."${DATENOW}")" ] && ok "Old $BCNADIR Backed UP"
else
 warn "Not Exist a Old $BCNADIR to be backeuped"
fi
if wget "$BCNADLINK" -P /tmp > /dev/null 2>&1 ; then 
 sudo chmod +x /tmp/"$BCNAD"
 ok "Latest Bitcanna-Cosmos Downloaded"
else
 erro "Latest bcna Cannot be downloaded"
fi
if [[ $(sha256sum /tmp/"$BCNAD") == "$BCNADLINKSHA  /tmp/$BCNAD" ]]; then 
 ok "Checksum sha256sum  OK"
else
 erro "Checksum sha256sum FAILED"
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

function cosmovisordownload(){
if wget "$COSMOVISORLINK" -P /tmp > /dev/null 2>&1 ; then 
 sudo chmod +x /tmp/"$COSMOV"
 ok "Latest Cosmovisor Downloaded"
else
 erro "Latest Cosmovisor Cannot be downloaded"
fi
if [[ $(sha256sum /tmp/"$COSMOV") == "$COSMOVISORLINKSHA  /tmp/$COSMOV" ]]; then 
 ok "Checksum sha256sum  OK"
else
 erro "Checksum sha256sum  FAIL"
fi
if [[ $(/tmp/"$COSMOV" version) == "$VERSIONNEW" ]] ; then
 sudo cp -P /tmp/"$COSMOV" /usr/local/bin/"$COSMOV"
else
 erro "Cannot copy cosmovisor to /usr/local/bin directory"
fi
}

function detectbcnacosmovisor(){
if [[ -f $(find "/usr/local/bin" -name "$BCNAD") ]] ; then
 MYBIN="$BCNAD"
elif [[ -f $(find "/usr/local/bin" -name "$COSMOV") ]] ; then
 MYBIN="$COSMOV"
else
 MYBIN="NONE"
fi
}

function checkin(){
detectbcnacosmovisor
intro
info "Welcome!\nChoose:\n(I)nstall , (R)emove :"
read -r choix
if [ "$choix" == "i" ] || [ "$choix" == "I" ]; then 
 info "New and Clean installation of Bitcanna and Cosmovisor wallet"
 if [[ "$MYBIN" == "NONE" ]] ; then
  bitcannadownload
  SettingConnection
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
  info " You want delegate ?! (Y|n)"
  read -r choicdeleg
  case "$choicdeleg" in
   y|Y) delegatecoins && break ;;
   n|N) warn "NOT Delegating coins" && break ;;
   *) warn "Wrong key" ;;
  esac 
  done
  prometheus
  while true
  do
  info "You like configure COSMOVISOR with BCNA? (Y/N)"
  read -r choiccosmovisor
  case "$choiccosmovisor" in
   y|Y) bcnacosmovisor && break ;;
   n|N) warn "Cosmovisor NOT configured..." && break ;;
   *) warn "Wrong key" ;;
  esac 
  done
  backup
  cleaner
 else
  erro "Detected $BCNAD/$COSMOV wallet already installed.\n"
 fi
elif [ "$choix" == "r" ] || [ "$choix" == "R" ] ; then 
 if [[ -a $(find "/usr/local/bin" -name "$BCNAD") ]] || [[ -a $(find "/usr/local/bin" -name "$COSMOV") ]] ; then
  info "Old Bitcanna-Cosmos version found"
  info "FULL REMOVING Bitcanna-Cosmos wallet"
  if sudo systemctl stop "$BCNAD".service > /dev/null 2>&1 ; then
   ok "Bitcanna Wallet Stopped"
  elif sudo systemctl stop "$COSMOV".service > /dev/null 2>&1 ; then
   ok "Cosmovisor Stopped"
  else 
   warn "Some problem on Stopping Wallet. Maybe stopped. Check it Manually"
  fi
  sleep 5
  cleaner
  sudo systemctl disable "$BCNAD".service || sudo systemctl disable "$COSMOV".service
  sudo rm -f /usr/local/bin/"$BCNAD" > /dev/null 2>&1 || warn "Cannot Delete /usr/local/bin/$BCNAD"
  sudo rm -f /usr/local/bin/"$COSMOV" > /dev/null 2>&1 || warn "Cannot Delete /usr/local/bin/$COSMOV"
  sudo systemctl disable "$BCNAD".service || warn "Cannot Disable $BCNAD.service"
  sudo systemctl disable "$COSMOV".service || warn "Cannot Disable $COSMOV.service"
  sudo systemctl daemon-reload || warn "Unable to Reload daemon services"
  sudo rm /lib/systemd/system/"$BCNAD".service || warn "Cannot remove /lib/systemd/system/$BCNAD.service"
  sudo rm /lib/systemd/system/"$COSMOV".service || warn "Cannot remove /lib/systemd/system/$COSMOV.service"
  if [[ ! -f "$BCNAUSERHOME"/REMOVEDBCNABACKUP ]] ; then
   mkdir -p "$BCNAUSERHOME"/REMOVEDBCNABACKUP
  fi
  cp -f -r --preserve "$BCNADIR" "$BCNAUSERHOME"/REMOVEDBCNABACKUP/.bcna."${DATENOW}" > /dev/null 2>&1 || erro "Cannot Copy $BCNADIR"
  sudo rm -R "$BCNADIR" > /dev/null 2>&1 || warn "Cannot Delete $BCNADIR"
  sudo ufw delete "$BCNAPORT" > /dev/null 2>&1 || warn "Remove rule from ufw for $BCNAPORT manually"
  ok "Bitcanna-Cosmos wallet was FULLY Removed"
 else
   erro "Bitcanna-Cosmos wallet not exist\n" && warn "Choose INSTALL"
 fi
else
 erro "Choose a correct option"
fi
}

function cleaner(){
info "Cleaning...."
sudo rm -r /tmp/*  > /dev/null 2>&1 && ok "/tmp folder cleaned"
history -cw
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
info "Choose method to recover your wallet:\n\t S - by Seed\n\t C - Create New Wallet"
read -r recwallet
case "$recwallet" in
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
faztsyncconfig
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
ExecStart=/usr/local/bin/$BCNAD start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > /tmp/"$BCNAD".service
 if sudo cp /tmp/"$BCNAD".service /lib/systemd/system/ && sudo systemctl enable "$BCNAD".service ; then
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
sleep 1 && warn "TIME TO CLAIM/SEND/ASK FOR COINS" && ok "Your Address: $MYWALLETADDR"
sleep 1 && warn "TIME TO CLAIM/SEND/ASK FOR COINS" && ok "Your Address: $MYWALLETADDR"
sleep 1 && warn "TIME TO CLAIM/SEND/ASK FOR COINS" && ok "Your Address: $MYWALLETADDR"
read -n 1 -s -r -p "$(info "Press any key to continue...\n\n")" && echo && echo
}

function faztsyncconfig(){
NODE1_IP="178.128.247.173"
RPC1="http://$NODE1_IP"
P2P_PORT1="26656"
RPC_PORT1="26657"
NODE2_IP="159.65.198.245"
RPC2="http://$NODE2_IP"
RPC_PORT2="26657"
P2P_PORT2="26656"
LATEST_HEIGHT=$(curl -s $RPC1:$RPC_PORT1/block | jq -r .result.block.header.height);
BLOCK_HEIGHT=$((($(("$LATEST_HEIGHT" / 1000)) -10) * 1000));
if [ "$BLOCK_HEIGHT" -eq 0 ]; then
 erro "Cannot state sync to block 0; Latest block is $LATEST_HEIGHT and must be at least 1000; wait a few blocks!"
fi
TRUST_HASH=$(curl -s "$RPC1:$RPC_PORT1/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
if [ "$TRUST_HASH" == "null" ]; then
 erro "Cannot find block hash. This shouldn't happen :/"
fi
NODE1_ID=$(curl -s "$RPC1:$RPC_PORT1/status" | jq -r .result.node_info.id)
NODE2_ID=$(curl -s "$RPC2:$RPC_PORT2/status" | jq -r .result.node_info.id)
PERSISTPEERS="${NODE1_ID}@${NODE1_IP}:${P2P_PORT1},${NODE2_ID}@${NODE2_IP}:${P2P_PORT2}"

# sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
#s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"http://$NODE1_IP:$RPC_PORT1,http://$NODE2_IP:$RPC_PORT2\"| ; \
#s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1\"$BLOCK_HEIGHT\"| ; \
#s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
#s|^(persistent_peers[[:space:]]+=[[:space:]]+).*$|\1\"${NODE1_ID}@${NODE1_IP}:${P2P_PORT1},${NODE2_ID}@${NODE2_IP}:${P2P_PORT2}\"| ; \
#s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"$SEEDS\"|" "$BCNADIR"/config/config.toml
sed -i.bak -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"http://$NODE1_IP:$RPC_PORT1,http://$NODE2_IP:$RPC_PORT2\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"$SEEDS\"|" "$BCNADIR"/config/config.toml
}

function backup(){
info "Backup Validator keys"
cd "$BCNACONF" || warn "Cannot access to .config file"
if tar -czf "$BCNAUSERHOME"/BCNABACKUP/validator_key.tar.gz ./*_key.json  ; then
 ok "*_key.json files Compressed"
 if gpg -o "$BCNAUSERHOME"/BCNABACKUP/validator_key.tar.gz.gpg -ca "$BCNAUSERHOME"/BCNABACKUP/validator_key.tar.gz ; then
  ok "Keys saved and un/encrypted on $BCNAUSERHOME/BCNABACKUP/validator_key.tar.gz/.gpg"
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
--from "$WALLETNAME" \
--min-self-delegation 1 \
--moniker "$MONIKER" \
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

function bcnacosmovisor(){
info "Configure BCNA to use Cosmovisor"
cosmovisordetection
cosmovisordownload
ln -s -f -T "${BCNADIR}"/cosmovisor/genesis "${BCNADIR}"/cosmovisor/current || erro "Unable to create symlink for genesis to cosmovisor current"
if [[ $(/tmp/"$BCNAD" version) == "$VERSIONNEW" ]] ; then
 sudo cp /tmp/"$BCNAD" "${BCNADIR}"/cosmovisor/genesis/bin/"$BCNAD" || erro "Unable copy bcnad to ${BCNADIR}/cosmovisor/genesis/bin/ directory"
fi
warn "You can check that everything is OK:"
ls .bcna/cosmovisor/ -lh
read -n 1 -s -r -p "$(info "Press any key to continue...")"
checkservicetype
info "Check $MYSERVICE.service Running"
if sudo systemctl is-active "$MYSERVICE".service > /dev/null 2>&1 ; then
 ok "$MYSERVICE.service Is Running"
else
 info "$MYSERVICE.service Is Starting"
 sudo systemctl start "$MYSERVICE".service
 sleep 5
fi
echo "[Unit]
Description=Cosmovisor BitCanna Service
After=network-online.target
[Service]
User=${USER}
Environment=DAEMON_NAME=$BCNAD
Environment=DAEMON_RESTART_AFTER_UPGRADE=true
Environment=DAEMON_HOME=$BCNADIR
ExecStart=/usr/local/bin/$COSMOV start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > /tmp/"$COSMOV".service
if sudo cp /tmp/"$COSMOV".service /lib/systemd/system/ && sudo systemctl daemon-reload ; then
 info "Check $BCNAD.service Stopped"
 if sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
  sudo systemctl stop "$BCNAD".service
  sudo systemctl disable "$BCNAD".service
  sudo rm /lib/systemd/system/"$BCNAD".service
  sudo systemctl daemon-reload
  ok "$BCNAD Stopped, Disabled and Removed"
 elif ! sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
  info "$BCNAD.service already stopped"
  sudo systemctl disable "$BCNAD".service
  sudo rm /lib/systemd/system/"$BCNAD".service
  sudo systemctl daemon-reload
  ok "$BCNAD.service Disabled and Removed"
 else
  erro "Something wrong with $BCNAD.service"
 fi
 if sudo rm /usr/local/bin/bcnad ; then
  ok "bcnad removed"
 else
  warn "Remove bcnad Manually. sudo rm /usr/local/bin/bcnad"
 fi
 if sudo systemctl enable "$COSMOV".service && sudo systemctl start "$COSMOV".service ;then
  ok "Bitcanna-cosmovisor Service Enabled and Started"
 else 
  erro "Problem Enabling/Starting Bitcanna-cosmovisor Service"
 fi
else 
 erro "Problem setting Bitcanna-cosmovisor Service"
fi
echo "export DAEMON_NAME=bcnad
export DAEMON_RESTART_AFTER_UPGRADE=true
export DAEMON_HOME=${HOME}/.bcna
PATH=\"$BCNADIR/cosmovisor/current/bin:$PATH\"" | tee -a "${HOME}"/.profile
. "${HOME}"/.profile
info "Commands:"
echo "Show cosmovisor Version: $COSMOV version
Show BCNA Version: $BCNAD version
Show Sync info: $COSMOV status"
info "Cosmovisor Service:
Stop Service: sudo service $COSMOV stop 
Start Service: sudo service $COSMOV start
Restart Service: sudo service $COSMOV restart
Check LOGS: sudo journalctl -u $COSMOV -f"
}

function cosmovisordetection(){
CODENAMENOWINDICA=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep -ioF "indica")
CODENAMENOWSATIVA=$(curl --silent "https://api.github.com/repos/BitCannaGlobal/$BCNACOSMOSREP/releases/latest" | grep -ioF "sativa")
if [ "$CODENAMENOWSATIVA" == "SATIVA" ] ; then
 ok "Sativa codename"
 info "Creating cosmovisor directories..."
 mkdir -p "${HOME}"/.bcna/cosmovisor/genesis/bin
 mkdir -p "${HOME}"/.bcna/cosmovisor/upgrades/sativa/bin
 CODENAME="SATIVA"
elif [ "$CODENAMENOWINDICA" == "INDICA" ] ; then
 ok "Indica codename"
 info "Creating cosmovisor directories..."
  mkdir -p "${HOME}"/.bcna/cosmovisor/genesis/bin
  mkdir -p "${HOME}"/.bcna/cosmovisor/upgrades/indica/bin
  CODENAME="INDICA"
else
 erro "Problem getting CODENAME sativa/indica"
fi
}

function checkservicetype(){
if systemctl --all --type service | grep -q cosmovisor ; then
 MYSERVICE="cosmovisor"
elif systemctl --all --type service | grep -q bcnad ; then
 MYSERVICE="bcnad"
fi
}

function prometheus() {
sed -i "s/prometheus = \".*\"/prometheus = true/" "$BCNACONF"/config.toml || warn "Cannot Enable Prometheus"
sed -i "s/prometheus_listen_addr = \".*\"/prometheus_listen_addr = \"0.0.0.0:26660\"/" "$BCNACONF"/config.toml || warn "Cannot Listen Address Prometheus"
sudo service "$BCNAD" restart || warn "Unable Restart Bitcanna by service. Check it Manually."
if sudo ufw allow from 167.172.43.16 proto tcp to any port 26660 ; then
 ok "UFW rule added to Prometheus analytics"
else
 warn "UFW rule NOT added to Prometheus analytics"
fi
syncr
}

function delegatecoins(){
info " Check CosmoCanna-Manager Script :) "
info " https://github.com/hellresistor/CosmoCanna/blob/main/CosmoCanna-Manager.sh"
info " Use, abuse and improove :)"
read -n 1 -s -r -p "$(info "Press any key to continue...")"
}

###############
###  Start  ###
###############
if [ -z "$MONIKER" ]; then
 erro "Set MONIKER var on this Script ..."
fi
if [[ "$MONIKER" = *" "* ]]; then
  erro "Please, NOT use SPACE character on Moniker"
fi
if [ -z "$WALLETNAME" ]; then
 erro "Set WALLETNAME on this Script ..."
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
 erro "Failing Check Requisites"
fi
checkin
concl
exit 0
