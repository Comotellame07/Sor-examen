#!bin/bash
apt update -y && apt upgrade -y
apt install nfs-kernel-server
read -p "¿Como se llamara tu servidor?"
