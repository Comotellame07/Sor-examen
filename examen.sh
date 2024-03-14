#!/bin/bash
menu() {
echo "Realizado por Dario Moreno"
echo "Bienvenido al menu de administración de SOR en Ubuntu"
echo "1. Configurar Netplan"
echo "2. Agregar unidad organizativa de 1ºnivel"
echo "3. Agregar unidad organizativa de 2ºnivel"
echo "4. Agregar grupo"
echo "5. Agregar usuario"
echo "6. Carpeta compartida"
echo "7. Perfil movil"
echo "8. Salir"
echo -n "Escoger opcion: "
read opcion
if [  $opcion = "1" ]
then
  servicio
elif [  $opcion = "2" ]
then
  netplan
elif [ $opcion = "3" ]
then
  ou1
elif [ $opcion = "4" ]
then
  ou2
elif [ $opcion = "5" ]
then
  gr
elif [ $opcion = "6" ]
then
  usr
elif [ $opcion = "7" ]
then
  nfs
elif [ $opcion = "8" ]
then
  movil
elif [ $opcion = "9" ]
then
  echo "Saliendo del programa..."
else
  clear
  menu
fi
}

###################################################################################
###################################################################################

servicio() {

}

###################################################################################
###################################################################################

netplan() {
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
read -p "¿Quieres DHCP activo?(y/n): " dhcp
if [ $dhcp = y ]
then
cat > /etc/netplan/00-installer-config.yaml <<EOF
network:
  version: 2
  ethernets:
    $nic
      dhcp4: true
EOF
sudo netplan apply
elif [ $dhcp = n ]
then
staticip
gatewayip
nameserversip
dominio
echo
cat > /etc/netplan/00-installer-config.yaml <<EOF
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
else
clear
echo "Repitelo, no se te entiende"
netplan
fi
}

nic=`ifconfig | awk 'NR==1{print $1}'`
netplan
echo "Netplan configurado"
}

###################################################################################
###################################################################################

ou1() {
    clear
    ./rs/ou1.sh
}

ou2() {
    clear
    ./rs/ou2.sh
}

gr() {
    clear
    ./rs/gr.sh
}

usr() {
    clear
    ./rs/usr.sh
}

nfs() {
    clear
    ./rs/nfs.sh
}

movil() {
    clear
    ./rs/movil.sh
}

chmod +x rs/nfs.sh
chmod +x rs/usr.sh
chmod +x rs/movil.sh
chmod +x rs/gr.sh
chmod +x rs/ou2.sh
chmod +x rs/ou1.sh
chmod +x rs/netplan.sh
menu
