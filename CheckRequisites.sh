#!/bin/bash
# shellcheck disable=SC1091
#---------------------------------------------------#
#  A BitCanna-Cosmos Community Installation Script  #
#                  REQUIREMENTS                     #   
#---------------------------------------------------#
. CONFIG
MYDEPPACKAGES=(build-essential curl wget jq ufw gnupg)

#### Software Requisites
info "Checking System Updates"
if sudo apt-get -y update > /dev/null 2>&1 && sudo apt-get -y upgrade > /dev/null 2>&1 ; then
 ok "System Updated"
else
 erro "System Outdated"
fi

## Installing dependencies ##
info "Installing Os Dependencies"
for deppkgs in "${MYDEPPACKAGES[@]}" ; do
 if command -v "$deppkgs" > /dev/null 2>&1; then
  info "Package $deppkgs is already Installed"
 else 
  if sudo apt-get -y install "$deppkgs" > /dev/null 2>&1; then
   ok "Package $deppkgs Installed"
  else
   erro "Unable install $deppkgs package"
  fi
 fi
done

if grep -Fxq "fs.file-max = 65536" /etc/sysctl.conf ; then
 warn "fs.file-max good"
else
 if sudo su -c "echo 'fs.file-max = 65536' >> /etc/sysctl.conf" ; then
  sudo sysctl -p
  ok "fs.file-max = 65536 defined"
 else
  erro "Unable set fs.file-max" 
 fi
fi



