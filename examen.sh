#!/bin/bash
menu() {
echo "Realizado por Dario Moreno"
echo "Bienvenido al menu de administración de SOR en Ubuntu"
echo "1. Instalar servicios necesarios (no hacer si ya estan instalados)"
echo "2. Configurar servicios necesarios (no hacer si se ha realizado la opcion 1)"
echo "3. Configurar Netplan"
echo "4. Agregar unidad organizativa de 1ºnivel"
echo "5. Agregar unidad organizativa de 2ºnivel"
echo "6. Agregar grupo"
echo "7. Agregar usuario"
echo "8. Carpeta compartida"
echo "9. Perfil movil"
echo "10. Salir"
echo -n "Escoger opcion: "
read opcion
if [ $opcion = "1" ]
then
  servicio
elif [ $opcion = "2" ]
then
  config
elif [ $opcion = "3" ]
then
  netplan
elif [ $opcion = "4" ]
then
  ou1
elif [ $opcion = "5" ]
then
  ou2
elif [ $opcion = "6" ]
then
  gr
elif [ $opcion = "7" ]
then
  usr
elif [ $opcion = "8" ]
then
  nfs
elif [ $opcion = "9" ]
then
  movil
elif [ $opcion = "10" ]
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
apt update -y && apt upgrade -y
apt install nfs-kernel-server -y
read -p "¿Como se llamara tu servidor(escribir con espacios)? ej: vegasoft1 vegasoft local = vegasoft1.vegasoft.local" nom1 nom2 nom3
hostnamectl set-hostname $nom1.$nom2.$nom3
read -p "¿Cual es la ip que tendra el servidor?" ip
cat >> /etc/hosts <<EOF
127.0.1.1 $nom1.$nom2.$nom3
$ip $nom1.$nom2.$nom3
EOF
apt install slapd ldap-utils -y
dpkg-reconfigure slapd
}

###################################################################################
###################################################################################

config() {
read -p "¿Como se llamara tu servidor(escribir con espacios)? ej: vegasoft1 vegasoft local = vegasoft1.vegasoft.local" nom1 nom2 nom3
hostnamectl set-hostname $nom1.$nom2.$nom3
read -p "¿Cual es la ip que tendra el servidor?" ip
cat >> /etc/hosts <<EOF
127.0.1.1 $nom1.$nom2.$nom3
$ip $nom1.$nom2.$nom3
EOF
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
nombre_ou() {
read -p "Nombre para la unidad organizativa de primer grado" nombre_ou
read -p "¿Estas seguro?(y/n)" resp
if [ $resp = "y" ]
then
creacion
elif [ $resp = "n" ]
then
nombre_ou
else
nombre_ou
fi
}

creacion() {
touch ou-$nombre_ou.ldif
cat > ou-$nombre_ou.ldif <<EOF
dn: ou=$nombre_ou,dc=$nom2,dc=$nom3
objectClass: organizationalUnit
ou: $nombre_ou
EOF
ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f ou-$nombre_ou.ldif
read -p "¿Quieres crear otra unidad organizativa de 1º nivel?(y/n)" resp
if [ $resp = "y" ]
then
nombre_ou
elif [ $resp = "n" ]
then
menu
else
menu
fi
}
}

###################################################################################
###################################################################################

ou2() {
nombre_ou2() {
read -p "Nombre para la unidad organizativa de segundo grado" nombre_ou2
read -p "Nombre para unidad de primer grado a la que pertenece" nombre_ou
read -p "¿Estas seguro?(y/n)" resp
if [ $resp = "y" ]
then
creacion2
elif [ $resp = "n" ]
then
nombre_ou2
else
nombre_ou2
fi
}

creacion2() {
touch ou-$nombre_ou2.ldif
cat > ou-$nombre_ou2.ldif <<EOF
dn: ou=$nombre_ou2,ou=$nombre_ou,dc=$nom2,dc=$nom3
objectClass: organizationalUnit
ou: $nombre_ou2
EOF
ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f ou-$nombre_ou2.ldif
read -p "¿Quieres crear otra unidad organizativa de 2º nivel?(y/n)" resp
if [ $resp = "y" ]
then
nombre_ou2
elif [ $resp = "n" ]
then
menu
else
menu
fi
}
}

###################################################################################
###################################################################################

gr() {
    clear
    ./rs/gr.sh
}

###################################################################################
###################################################################################

usr() {
    clear
    ./rs/usr.sh
}

###################################################################################
###################################################################################

nfs() {
    clear
    ./rs/nfs.sh
}

###################################################################################
###################################################################################

movil() {
    clear
    ./rs/movil.sh
}

###################################################################################
###################################################################################

menu
