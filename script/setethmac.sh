#!/bin/bash
get_random_mac ()
{
local prefixes=("02" "06" "0A" "0E")
local random=$(shuf -i 0-3 -n 1)
MACADDR=$(printf ${prefixes[$random]}':%02X:%02X:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])
}


# set fixed IP address from first randomly assigned one. If nothing is deteceted, generate one.
set_fixed_mac ()
{

CONNECTION="$(nmcli -f UUID,ACTIVE,DEVICE,TYPE connection show --active | tail -n1)"
UUID=$(awk -F" " '/ethernet/ {print $1}' <<< "${CONNECTION}")
DEVNAME=$(awk -F" " '/ethernet/ {print $3}' <<< "${CONNECTION}")
#MACADDR=$(/sbin/ip link | grep -A1 ${DEVNAME} | awk -F" " '/ether / {print $2}')

[[ -z $MACADDR ]] && get_random_mac

if [[ -n $UUID ]]; then
	nmcli connection modify $UUID ethernet.cloned-mac-address $MACADDR
	nmcli connection modify $UUID -ethernet.mac-address ""
	nmcli connection down $UUID >/dev/null 2>&1
	nmcli connection up $UUID >/dev/null 2>&1
	return 0
fi
} # set fixed mac to the 1st active network adapter

set_fixed_mac
