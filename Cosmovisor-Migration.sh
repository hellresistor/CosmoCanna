#!/bin/bash
# shellcheck disable=SC1091
#---------------------------------------------#
#          Cosmovisor Migration Tool          #
#---------------------------------------------#
#              Version: V1.02                 #
#          Donate BitCanna Address:           #
# bcna14dz7zytpenkyyktqvzq2mw7msfyp0y3zg48xqw #
#---------------------------------------------#

########
# EDIT #
TESTVER="v0.testnet7"
BCNAD="bcnad"
COSMOV="cosmovisor"

VERSIONNOW="" # Actual Version
VERSIONUPGRADE="" # Upgrade Version
########

. CONFIG

if [[ ! -f ${HOME}/.bcna/cosmovisor ]]; then
 info "Creating cosmovisor directories..."
 mkdir -p "${HOME}"/.bcna/cosmovisor/genesis/bin
 mkdir -p "${HOME}"/.bcna/cosmovisor/upgrades/sativa/bin
else
 info "Moving old .bcna/cosmovisor folder"
 mv "${HOME}"/.bcna/cosmovisor "${HOME}"/.bcna/cosmovisor."$DATENOW"
 info "Creating cosmovisor directories..."
 mkdir -p "${HOME}"/.bcna/cosmovisor/genesis/bin
 mkdir -p "${HOME}"/.bcna/cosmovisor/upgrades/sativa/bin
fi

info "Getting cosmovisor and bcnad"
wget https://github.com/BitCannaGlobal/testnet-bcna-cosmos/releases/download/$TESTVER/cosmovisor || erro "Cant download Cosmovisor "
if [[ $(sha256sum ./cosmovisor) == "5716eeef98f4f8efa98c95c234b539fdb9efca07c1b7e8c498cd5268dc1a5a8c" ]]; then 
 ok "Checksum sha256sum  OK"
else
 erro "Checksum sha256sum  FAIL"
fi
chmod +x cosmovisor
if [[ $(./cosmovisor version) == "$TESTVER" ]] ; then
 sudo mv cosmovisor /usr/local/bin || erro "Cannot copy cosmovisor to /usr/local/bin directory"
fi

wget -nc https://github.com/BitCannaGlobal/testnet-bcna-cosmos/releases/download/$TESTVER/bcnad || erro "Cant download bcnad "
if [[ $(sha256sum ./bcnad) == "d36d6df2a8155a92f4c6a9696ac38e4878ec750d5dff9ad8a5c5e3fadbea6edb" ]]; then 
 ok "Checksum sha256sum  OK"
else
 erro "Checksum sha256sum  FAIL"
fi
chmod +x bcnad
if [[ $(./bcnad version) == "$TESTVER" ]] ; then
 mv ./bcnad "${HOME}"/.bcna/cosmovisor/upgrades/sativa/bin/bcnad
fi

cp "$(command -v bcnad)" "${HOME}"/.bcna/cosmovisor/genesis/bin/ || erro "Unable copy bcnad to ${HOME}/.bcna/cosmovisor/genesis/bin/ directory"
ln -s -T "${HOME}"/.bcna/cosmovisor/genesis "${HOME}"/.bcna/cosmovisor/current
warn "You can check that everything is OK:"
ls .bcna/cosmovisor/ -lh
read -n 1 -s -r -p "$(info "Press any key to continue...")"

echo "[Unit]
Description=Cosmovisor BitCanna Service
After=network-online.target
[Service]
User=${USER}
Environment=DAEMON_NAME=bcnad
Environment=DAEMON_RESTART_AFTER_UPGRADE=true
Environment=DAEMON_HOME=${HOME}/.bcna
ExecStart=$(command -v cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > /tmp/"$COSMOV".service

if sudo mv /tmp/"$COSMOV".service /lib/systemd/system/ && sudo systemctl daemon-reload ; then
 info "Check $BCNAD.service Stopped"
 if sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
  sudo systemctl stop "$BCNAD"
  sudo systemctl disable "$BCNAD"
  sudo rm /lib/systemd/system/"$BCNAD".service
  ok "$BCNAD Stopped, Disabled and Removed"
 elif ! sudo systemctl is-active "$BCNAD".service > /dev/null 2>&1 ; then
  info "$BCNAD.service already stopped"
  sudo systemctl disable "$BCNAD"
  sudo rm /lib/systemd/system/"$BCNAD".service
  ok "$BCNAD.service Disabled and Removed"
 else
  erro "Something wrong with $BCNAD.service"
 fi
 if sudo systemctl enable "$COSMOV".service && sudo systemctl start "$COSMOV".service ; then 
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
PATH=\"${HOME}/.bcna/cosmovisor/current/bin:$PATH\"" | tee -a "${HOME}"/.profile
source .profile

info "Commands:"
echo "Show cosmovisor Version: $COSMOV version
Show BCNA Version: $BCNAD version
Show Sync info: $COSMOV status"
info "Cosmovisor Service:
Stop Service: sudo service $COSMOV stop 
Start Service: sudo service $COSMOV start
Restart Service: sudo service $COSMOV restart
Check LOGS: sudo journalctl -u $COSMOV -f"

if sudo rm /usr/local/bin/bcnad ; then
 ok "bcnad removed"
else
 warn "Remove bcnad Manually. sudo rm /usr/local/bin/bcnad"
fi
