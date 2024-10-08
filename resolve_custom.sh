#!/bin/bash

# motivation: dns is not working on wsl2 with vpn connectin
# resolution: update resolve.conf when starting wsl
#
# 1. in /etc/wsl.conf comment: 
## #[network]
## #generateResolvConf = false
# 2. place this script at /bin/wsl2_vpn_dns.sh
# 3. make it executable under sudo:
## sudo chmod +x /bin/wsl2_vpn_dns.sh
## echo "$(whoami) ALL=(ALL) NOPASSWD: /bin/wsl2_vpn_dns.sh" | sudo tee /etc/sudoers.d/010-$(whoami)-wsl2-vpn-dns
# 4. make it run on wsl startup
## echo "sudo /bin/wsl2_vpn_dns.sh" | sudo tee /etc/profile.d/wsl2-vpn-dns.sh
# 5. remove immutable flag from resolv.conf
## sudo chattr -i /etc/resolv.conf
#
# to run it manually: sudo /bin/wsl2_vpn_dns.sh
#
# "Cisco AnyConnect*" for anyconnect
# "PANGP*" for globalprotect
#

if [[ $1 == "help" ]]; then
  echo "help"
elif [[ $1 == "google" ]]; then
  echo "set dns to google"
  printf "# Generated by vpn fix func\nnameserver 8.8.8.8\nnameserver 8.8.4.4\n" > /etc/resolv.conf
elif [[ $1 == "vpn" ]]; then
  echo "Getting current DNS servers, this takes a couple of seconds"

  /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command '
$ErrorActionPreference="SilentlyContinue"
Get-NetAdapter -InterfaceDescription "PANGP*" | Get-DnsClientServerAddress | Select -ExpandProperty ServerAddresses
Get-NetAdapter | ?{-not ($_.InterfaceDescription -like "PANGP*") } | Get-DnsClientServerAddress | Select -ExpandProperty ServerAddresses
' | \
        awk 'BEGIN { print "# Generated by vpn fix func"; print } { print "nameserver", $1 }' | \
        tr -d '\r' > /etc/resolv.conf
fi
printf "Current resolv.conf:\n-------------------\n\n"
cat /etc/resolv.conf

#clear
