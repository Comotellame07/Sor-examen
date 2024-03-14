#!/bin/bash

# Función principal del menú
menu() {
    clear
    echo "Realizado por Dario Moreno"
    echo ""
    echo "Bienvenido al menu de administración de SOR en Ubuntu, todos los archivos de configuracion seran guardados en el directorio /etc/SorScript"
    echo ""
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
    echo ""
    echo -n "Escoger opcion: "
    read opcion
    if [ $opcion = "1" ]; then
        servicio
    elif [ $opcion = "2" ]; then
        config
    elif [ $opcion = "3" ]; then
        netplan
    elif [ $opcion = "4" ]; then
        crearou1
    elif [ $opcion = "5" ]; then
        crearou2
    elif [ $opcion = "6" ]; then
        creargr
    elif [ $opcion = "7" ]; then
        crearusr
    elif [ $opcion = "8" ]; then
        crearnfs
    elif [ $opcion = "9" ]; then
        crearmovil
    elif [ $opcion = "10" ]; then
        echo "Saliendo del programa..."
    else
        clear
        menu
    fi
}

# Función para instalar servicios necesarios
servicio() {
    apt update -y && apt upgrade -y
    apt install nfs-kernel-server -y
    echo "¿Como se llamara tu servidor(escribir con espacios)? ej: vegasoft1 vegasoft local = vegasoft1.vegasoft.local"
    read nom1 nom2 nom3
    hostnamectl set-hostname $nom1.$nom2.$nom3
    echo "¿Cual es la ip que tendra el servidor?"
    read ip
    cat >> /etc/hosts <<EOF
127.0.1.1 $nom1.$nom2.$nom3
$ip $nom1.$nom2.$nom3
EOF
    apt install slapd ldap-utils -y
    dpkg-reconfigure slapd
    menu
}

# Función para configurar servicios necesarios
config() {
    read -p "¿Como se llamara tu servidor(escribir con espacios)? ej: vegasoft1 vegasoft local = vegasoft1.vegasoft.local" nom1 nom2 nom3
    hostnamectl set-hostname $nom1.$nom2.$nom3
    read -p "¿Cual es la ip que tendra el servidor?" ip
    cat >> /etc/hosts <<EOF
127.0.1.1 $nom1.$nom2.$nom3
$ip $nom1.$nom2.$nom3
EOF
    menu
}

# Función para configurar Netplan
netplan() {
    staticip() {
        read -p "IP Estática Ej. 192.168.100.10/24: " staticip
        read -p "¿Estas seguro?(y/n)" resp
        if [ $resp = "y" ]; then
            echo "OK"
        elif [ $resp = "n" ]; then
            staticip
        else
            staticip
        fi
    }

    gatewayip() {
        read -p "IP router: " gatewayip
        read -p "¿Estas seguro?(y/n)" resp
        if [ $resp = "y" ]; then
            echo "OK"
        elif [ $resp = "n" ]; then
            gatewayip
        else
            gatewayip
        fi
    }

    nameserversip() {
        read -p "Servidores DNS: " nameserversip
        read -p "¿Estas seguro?(y/n)" resp
        if [ $resp = "y" ]; then
            echo "OK"
        elif [ $resp = "n" ]; then
            nameserversip
        else
            nameserversip
        fi
    }

    netplan() {
        read -p "¿Quieres DHCP activo?(y/n): " dhcp
        if [ $dhcp = y ]; then
            cat > /etc/netplan/00-installer-config.yaml <<EOF
network:
  version: 2
  ethernets:
    $nic
      dhcp4: true
EOF
            sudo netplan apply
        elif [ $dhcp = n ]; then
            staticip
            gatewayip
            nameserversip
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

    nic=$(ifconfig | awk 'NR==1{print $1}')
    netplan
    menu
}

# Función para agregar unidad organizativa de primer grado
crearou1() {
    nombre_ou() {
        read -p "Nombre para la unidad organizativa de primer grado" nombre_ou
        read -p "¿Estas seguro?(y/n)" resp
        if [ $resp = "y" ]; then
            creacion
        elif [ $resp = "n" ]; then
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
        if [ $resp = "y" ]; then
            nombre_ou
        elif [ $resp = "n" ]; then
            menu
        else
            menu
        fi
    }
}

# Función para agregar unidad organizativa de segundo grado
crearou2() {
    nombre_ou2() {
        read -p "Nombre para la unidad organizativa de segundo grado" nombre_ou2
        read -p "Nombre para unidad de primer grado a la que pertenece" nombre_ou
        read -p "¿Estas seguro?(y/n)" resp
        if [ $resp = "y" ]; then
            creacion2
        elif [ $resp = "n" ]; then
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
        if [ $resp = "y" ]; then
            nombre_ou2
        elif [ $resp = "n" ]; then
            menu
        else
            menu
        fi
    }
}

# Función para agregar grupo
creargr() {
    nombre_gr() {
        read -p "Nombre para el grupo" nombre_gr
        read -p "Nombre para unidad organizativa a la que pertenece" nombre_ou
        read -p "gidNumber para el grupo" gid_gr
        read -p "¿Estas seguro?(y/n)" resp
        if [ $resp = "y" ]; then
            creaciongr
        elif [ $resp = "n" ]; then
            nombre_gr
        else
            nombre_gr
        fi
    }

    creaciongr() {
        touch gr-$nombre_gr.ldif
        cat > gr-$nombre_gr.ldif <<EOF
dn: cn=$nombre_gr,ou=$nombre_ou,dc=$nom2,dc=$nom3
objectClass: posixGroup
cn: $nombre_gr
gidNumber: $gid_gr
EOF
        ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f ou-$nombre_gr.ldif
        read -p "¿Quieres crear otro grupo?(y/n)" resp
        if [ $resp = "y" ]; then
            nombre_gr
        elif [ $resp = "n" ]; then
            menu
        else
            menu
        fi
    }
}

# Función para agregar usuario
crearusr() {
    nombre_usr() {
        read -p "Nombre para el usuario" nombre_usr
        read -p "Nombre de la unidad organizativa a la que pertenece" nombre_ou
        read -p "Nombre del grupo al que pertenece" nombre_gr
        read -p "uidNumber del usuario" uid_usr
        read -p "gidNumber del usuario" gid_usr
        read -p "E-mail del usuario ej: dario@vegasoft.local" mail_usr
        contrasena=$(slappasswd)
        read -p "¿Estas seguro de todos los ajustes?(y/n)" resp
        if [ $resp = "y" ]; then
            creacionusr
        elif [ $resp = "n" ]; then
            nombre_usr
        else
            nombre_usr
        fi
    }

    creacionusr() {
        touch usr-$nombre_usr.ldif
        cat > usr-$nombre_usr.ldif <<EOF
dn: uid=$nombre_usr,ou=$nombre_ou,dc=$nom2,dc=$nom3
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: person
cn: $nombre_usr
uid: $nombre_usr
ou: $nombre_gr
uidNumber: $uid_usr
gidNumber: $gid_usr
homeDirectory: /home/$nombre_usr
loginShell: /bin/bash
userPassword: $contraseña
sn: $nombre_usr
mail: $mail_usr
givenName: $nombre_usr
EOF
        ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f ou-$nombre_gr.ldif
        read -p "¿Quieres crear otro usuario?(y/n)" resp
        if [ $resp = "y" ]; then
            nombre_usr
        elif [ $resp = "n" ]; then
            menu
        else
            menu
        fi
    }
}

# Función para carpeta compartida
crearnfs() {
    clear
    ./rs/nfs.sh
}

# Función para perfil móvil
crearmovil() {
    clear
    ./rs/movil.sh
}

echo "El programa ha de estar ejecutado desde la cuenta root tienes 10 segundos para cancelar si se ha iniciado desde otra cuenta"
echo "10"
sleep 1
echo "9"
sleep 1
echo "8"
sleep 1
echo "7"
sleep 1
echo "6"
sleep 1
echo "5"
sleep 1
echo "4"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
mkdir /etc/SorScript
cd /etc/SorScript
clear
menu
