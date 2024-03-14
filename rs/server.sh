#!/bin/bash
staticip() {
read -p "IP Estática Ej. 192.168.100.10/24: " staticip
read -p "¿Estas seguro?(y/n)" resp
if [ $resp = "y" ]
then
echo "OK"
elif [ $resp = "n" ]
then
staticip
else
staticip
fi
}

gatewayip() {
read -p "IP router: " gatewayip
read -p "¿Estas seguro?(y/n)" resp
if [ $resp = "y" ]
then
echo "OK"
elif [ $resp = "n" ]
then
gatewayip
else
gatewayip
fi
}

nameserversip() {
read -p "Servidores DNS: " nameserversip
read -p "¿Estas seguro?(y/n)" resp
if [ $resp = "y" ]
then
echo "OK"
elif [ $resp = "n" ]
then
nameserversip
else
nameserversip
fi
}

netplan() {
nic=`ifconfig | awk 'NR==1{print $1}'`
staticip
gatewayip
nameserversip
dominio
echo
cat > /etc/netplan/01-network-manager-all.yaml <<EOF
network:
  version: 2
  ethernets:
    $nic
      dhcp4: false
      addresses:
      - $staticip
      gateway4: $gatewayip
      nameservers:
       addresses: [$nameserversip]
EOF
sudo netplan apply
echo "Netplan configurado correctamente"
}
