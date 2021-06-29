#!/bin/bash
# shellcheck disable=SC1091
#---------------------------------------------------#
#  A BitCanna-Cosmos Community Installation Script  #
#                 Checking System                   #   
#---------------------------------------------------#

. CONFIG
case $(uname -m) in
 x86_64) packages=(git unzip wget zip) ;;
 *) erro "$(uname -m) Not Valid" ;;
esac

if [[ "$EUID" -eq 0 ]]; then 
 erro "You are root, not valid ;)"
else
 MYSUDOER=$(sudo grep '^$USER' /etc/sudoers)
 if [[ "$MYSUDOER" -eq 0 ]]; then
  ok "$USER is a sudoer user"
 else
  erro "User: $USER is not a sudoer user"
 fi
fi

info "Checking System Compatibility..."
## CPU Cores Checking...
if [[ $(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}') -ge 2 ]] ; then
 ok ">= 2 Cores"
else
 erro "< 2 Cores, Upgrade more"
fi

## RAM Checking...
if [[ $(awk '/MemTotal/ {print $2}' /proc/meminfo) -ge 4000000 ]] ; then
 ok ">= 4GB RAM"
else
 erro "< 4GB RAM, Upgrade more"
fi

## Storage avaliable Checking ...
DISKTYPE=$(lsblk -d | tail -n+2 | awk '{print $1}')
if [[ $DISKTYPE == *"sda"* ]]; then
 DISKSIZE=$(df | grep '^/dev/sda1' | awk '{s+=$2} END {print s/1048576}')
elif [[ $DISKTYPE == *"vda"* ]]; then
 DISKSIZE=$(df | grep '^/dev/vda1' | awk '{s+=$2} END {print s/1048576}')
elif [[ $DISKTYPE == *"hda"* ]]; then
 DISKSIZE=$(df | grep '^/dev/hda1' | awk '{s+=$2} END {print s/1048576}')
else
 erro "Invalid Disk partition. Run and Check: lsblk -d"
fi
DISKSIZEREDUCT=${DISKSIZE%.*}
if [[ "$DISKSIZEREDUCT" -ge 80 ]] ; then
 ok ">= 80 GB"
else
 erro "< 80 GB, Upgrade more"
fi
