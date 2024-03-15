
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
crearnfs
