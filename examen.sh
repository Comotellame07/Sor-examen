#!/bin/bash

menu() {
    clear
    echo "Realizado por Dario Moreno"
    echo ""
    echo "Bienvenido al menu de administración de SOR en Ubuntu, todos los archivos de configuracion seran guardados en el directorio /etc/SorScript"
    echo ""
    echo "1. Configurar Netplan (importante hacer primero)"
    echo "2. Instalar servicios necesarios (no hacer si ya estan instalados)"
    echo "3. Configurar servicios necesarios (obligatoria, pero no hacer si se ha realizado la opcion 2)"
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

    case $opcion in
        1) clear; netplan ;;
        2) clear; servicio ;;
        3) clear; config ;;
        4) clear; crearou1 ;;
        5) clear; crearou2 ;;
        6) clear; creargr ;;
        7) clear; crearusr ;;
        8) clear; crearnfs ;;
        9) clear; crearmovil ;;
        10) echo "Saliendo del programa..."; exit ;;
        *) clear; menu ;;
    esac
}

servicio() {
    apt update -y
    apt install nfs-kernel-server -y
    clear
    echo "¿Como se llamara tu servidor(escribir con espacios)? ej: vegasoft1 vegasoft local = vegasoft1.vegasoft.local"
    read -p "Nombre: " nom1 nom2 nom3
    hostnamectl set-hostname "$nom1.$nom2.$nom3"
    echo "¿Cual es la ip que tendra el servidor?: "
    read -p "IP: " ip
    cat >> /etc/hosts <<EOF
127.0.1.1 $nom1.$nom2.$nom3
$ip $nom1.$nom2.$nom3
EOF
    apt install slapd ldap-utils -y
    dpkg-reconfigure slapd
    clear
    echo "Antes de continuar ejecuta en tu maquina cliente 'sudo apt-get update -y' y 'sudo apt install openssh-server -y'."
    echo "Una vez instalado vuelve aqui y dale al enter"
    read
    read -p "¿Cual es el usuario administrador de la maquina cliente?: " UsuCli
    read -p "¿Cual es la ip de la maquina cliente?: " IpCli
    ssh "$UsuCli@$IpCli" 'sudo -S apt-get install nfs-common rpcbind -y && sudo -S chmod -R 777 /mnt/nfs && exit'
    menu
}

config() {
    echo "¿Como se llamara tu servidor(escribir con espacios)? ej: vegasoft1 vegasoft local = vegasoft1.vegasoft.local"
    read -p "Nombre: " nom1 nom2 nom3
    hostnamectl set-hostname "$nom1.$nom2.$nom3"
    echo "¿Cual es la ip que tendra el servidor?"
    read -p "IP: " ip
    cat >> /etc/hosts <<EOF
127.0.1.1 $nom1.$nom2.$nom3
$ip $nom1.$nom2.$nom3
EOF
    dpkg-reconfigure slapd
    clear
    echo "Antes de continuar ejecuta en tu maquina cliente 'sudo apt-get update -y' y 'sudo apt install openssh-server -y'."
    echo "Una vez instalado vuelve aqui y dale al enter"
    read
    read -p "¿Cual es el usuario administrador de la maquina cliente?: " UsuCli
    read -p "¿Cual es la ip de la maquina cliente?: " IpCli
    ssh "$UsuCli@$IpCli" 'sudo -S chmod -R 777 /mnt/nfs && exit'
    menu
}

netplan() {
    staticip() {
        read -p "IP Estática Ej. 192.168.100.10/24: " staticip
        read -p "¿Estas seguro?(y/n): " resp
        if [ "$resp" = "y" ]; then
            echo "OK"
        elif [ "$resp" = "n" ]; then
            staticip
        else
            staticip
        fi
    }

    gatewayip() {
        read -p "IP router: " gatewayip
        read -p "¿Estas seguro?(y/n): " resp
        if [ "$resp" = "y" ]; then
            echo "OK"
        elif [ "$resp" = "n" ]; then
            gatewayip
        else
            gatewayip
        fi
    }

    nameserversip() {
        read -p "Servidores DNS: " nameserversip
        read -p "¿Estas seguro?(y/n): " resp
        if [ "$resp" = "y" ]; then
            echo "OK"
        elif [ "$resp" = "n" ]; then
            nameserversip
        else
            nameserversip
        fi
    }

    netplan() {
        read -p "¿Quieres DHCP activo?(y/n): " dhcp
        if [ "$dhcp" = y ]; then
            cat > /etc/netplan/00-installer-config.yaml <<EOF
network:
  version: 2
  ethernets:
    $nic
      dhcp4: true
EOF
            sudo netplan apply
        elif [ "$dhcp" = n ]; then
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

crearou1() {
    nombre_ou() {
        read -p "Nombre para la unidad organizativa de primer grado: " nombre_ou
        read -p "¿Estas seguro?(y/n): " resp
        if [ "$resp" = "y" ]; then
            creacion
        elif [ "$resp" = "n" ]; then
            nombre_ou
        else
            nombre_ou
        fi
    }

    creacion() {
        touch "/etc/SorScript/ou-$nombre_ou.ldif"
        cat > "/etc/SorScript/ou-$nombre_ou.ldif" <<EOF
dn: ou=$nombre_ou,dc=$nom2,dc=$nom3
objectClass: top
objectClass: organizationalUnit
ou: $nombre_ou
EOF
        ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f "/etc/SorScript/ou-$nombre_ou.ldif"
        read -p "¿Quieres crear otra unidad organizativa de 1º nivel?(y/n): " resp
        if [ "$resp" = "y" ]; then
            nombre_ou
        elif [ "$resp" = "n" ]; then
            menu
        else
            menu
        fi
    }
    nombre_ou
}

crearou2() {
    nombre_ou2() {
        read -p "Nombre para la unidad organizativa de segundo grado: " nombre_ou2
        read -p "Nombre para unidad de primer grado a la que pertenece: " nombre_ou
        read -p "¿Estas seguro?(y/n): " resp
        if [ "$resp" = "y" ]; then
            creacion2
        elif [ "$resp" = "n" ]; then
            nombre_ou2
        else
            nombre_ou2
        fi
    }

    creacion2() {
        touch "/etc/SorScript/ou-$nombre_ou2.ldif"
        cat > "/etc/SorScript/ou-$nombre_ou2.ldif" <<EOF
dn: ou=$nombre_ou2,ou=$nombre_ou,dc=$nom2,dc=$nom3
objectClass: top
objectClass: organizationalUnit
ou: $nombre_ou2
EOF
        ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f "/etc/SorScript/ou-$nombre_ou2.ldif"
        read -p "¿Quieres crear otra unidad organizativa de 2º nivel?(y/n): " resp
        if [ "$resp" = "y" ]; then
            nombre_ou2
        elif [ "$resp" = "n" ]; then
            menu
        else
            menu
        fi
    }
    nombre_ou2
}

creargr() {
    nombre_gr() {
        read -p "Nombre para el grupo: " nombre_gr
        read -p "Nombre para unidad organizativa a la que pertenece: " nombre_ou
        read -p "gidNumber para el grupo: " gid_gr
        read -p "¿Estas seguro?(y/n): " resp
        if [ "$resp" = "y" ]; then
            creaciongr
        elif [ "$resp" = "n" ]; then
            nombre_gr
        else
            nombre_gr
        fi
    }

    creaciongr() {
        touch "/etc/SorScript/gr-$nombre_gr.ldif"
        cat > "/etc/SorScript/gr-$nombre_gr.ldif" <<EOF
dn: cn=$nombre_gr,ou=$nombre_ou,dc=$nom2,dc=$nom3
objectClass: top
objectClass: posixGroup
cn: $nombre_gr
gidNumber: $gid_gr
EOF
        ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f "/etc/SorScript/gr-$nombre_gr.ldif"
        read -p "¿Quieres crear otro grupo?(y/n): " resp
        if [ "$resp" = "y" ]; then
            nombre_gr
        elif [ "$resp" = "n" ]; then
            menu
        else
            menu
        fi
    }
    nombre_gr
}

crearusr() {
    nombre_usr() {
        read -p "Nombre para el usuario: " nombre_usr
        read -p "Nombre de la unidad organizativa a la que pertenece: " nombre_ou
        read -p "Nombre del grupo al que pertenece: " nombre_gr
        read -p "uidNumber del usuario: " uid_usr
        read -p "gidNumber del usuario: " gid_usr
        read -p "E-mail del usuario (ej: dario@vegasoft.local): " mail_usr
        echo "Contraseña para el usuario"
        contrasena=$(slappasswd)
        read -p "¿Estas seguro de todos los ajustes?(y/n): " resp
        if [ "$resp" = "y" ]; then
            creacionusr
        elif [ "$resp" = "n" ]; then
            nombre_usr
        else
            nombre_usr
        fi
    }

    creacionusr() {
        touch "/etc/SorScript/usr-$nombre_usr.ldif"
        cat > "/etc/SorScript/usr-$nombre_usr.ldif" <<EOF
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
userPassword: $contrasena
sn: $nombre_usr
mail: $mail_usr
givenName: $nombre_usr
EOF
        ldapadd -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f "/etc/SorScript/usr-$nombre_usr.ldif"
        read -p "¿Quieres crear otro usuario?(y/n): " resp
        if [ "$resp" = "y" ]; then
            nombre_usr
        elif [ "$resp" = "n" ]; then
            menu
        else
            menu
        fi
    }
    nombre_usr
}

crearnfs() {
    nombre_dir() {
        read -p "Nombre para la carpeta a compartir: " nombre_dir
        read -p "Ip del equipo actual: " IpSer
        read -p "Ip del equipo al que se le va a compartir la carpeta: " IpCli
        read -p "Usuario del equipo al que se le va a compartir la carpeta: " UsuCli
        read -p "Contraseña del equipo al que se le va a compartir la carpeta: " PwCli
        read -p "¿Estas seguro de todos los ajustes?(y/n): " resp
        if [ "$resp" = "y" ]; then
            creaciondir
        elif [ "$resp" = "n" ]; then
            nombre_dir
        else
            nombre_dir
        fi
    }

    creaciondir() {
        mkdir "/$nombre_dir"
        chown nobody:nogroup "/$nombre_dir"
        chmod -R 777 "/$nombre_dir"
        cat >> /etc/exports <<EOF
/$nombre_dir *(rw,sync,no_subtree_check)
EOF
        systemctl restart nfs-kernel-server
        ssh "$UsuCli@$IpCli" "sudo -S mkdir -p /mnt/nfs/$nombre_dir && sudo -S mount $IpSer:/$nombre_dir /mnt/nfs/$nombre_dir"
        read -p "¿Quieres crear otra carpeta compartida?(y/n): " resp
        if [ "$resp" = "y" ]; then
            nombre_dir
        elif [ "$resp" = "n" ]; then
            menu
        else
            menu
        fi
    }
    nombre_dir
}

crearmovil() {
    nombre_per() {
        read -p "Nombre del usuario a agregar el perfil movil: " nombre_usu
        read -p "Unidad organizativa del usuario: " nombre_ou
        read -p "Nombre de la carpeta base para los perfiles moviles: " nombre_dir
        read -p "Ip del equipo actual: " IpSer
        read -p "Ip del equipo cliente: " IpCli
        read -p "Usuario del equipo cliente con administrador: " UsuCli
        read -p "Contraseña del usuario: " PwCli
        read -p "¿Estas seguro de todos los ajustes?(y/n): " resp
        if [ "$resp" = "y" ]; then
            creacionper
        elif [ "$resp" = "n" ]; then
            nombre_per
        else
            nombre_per
        fi
    }

    creacionper() {
        mkdir "/$nombre_dir"
        chown nobody:nogroup "/$nombre_dir"
        cat >> /etc/exports <<EOF
/$nombre_dir $IpCli(rw,sync,no_root_squash,no_subtree_check)
EOF
        /etc/init.d/nfs-kernel-server restart
        touch /etc/SorScript/temporal.ldif
        cat > /etc/SorScript/temporal.ldif <<EOF
dn: uid=$nombre_usr,ou=$nombre_ou,dc=$nom2,dc=$nom3
changetype: modify
replace: homeDirectory
homeDirectory: /$nombre_dir/$nombre_usu
EOF
        ldapmodify -x -D "cn=admin,dc=$nom2,dc=$nom3" -W -f /etc/SorScript/temporal.ldif
        ssh "$UsuCli@$IpCli" "sudo -S mkdir /$nombre_dir && sudo -S chmod 777 /$nombre_dir && echo "$IpSer:/$nombre_dir /$nombre_dir nfs auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" | sudo tee -a /etc/fstab"
        read -p "¿Quieres crear otro perfil movil?(y/n): " resp
        if [ "$resp" = "y" ]; then
            nombre_per
        elif [ "$resp" = "n" ]; then
            menu
        else
            menu
        fi
    }
    read -p "Se necesita tener un usuario creado para esta opcion, ¿estas seguro de que quieres continuar?(y/n): " resp
    if [ "$resp" = "y" ]; then
        nombre_per
    elif [ "$resp" = "n" ]; then
        menu
    else
        menu
    fi
}

if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse con privilegios de superusuario. Para ello ejecute el comando 'sudo su'" >&2
    exit 1
fi

mkdir -p /etc/SorScript
menu
