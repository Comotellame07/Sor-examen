#!/bin/bash

# Crear unidad organizativa "control"
cat <<EOF > ou-control.ldif
dn: ou=control,dc=vegasoft,dc=local
objectClass: organizationalUnit
ou: control
EOF
sudo ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W -f ou-control.ldif
# Crear unidad organizativa "personal" dentro de "control"
cat <<EOF > ou-personal.ldif
dn: ou=personal,ou=control,dc=vegasoft,dc=local
objectClass: organizationalUnit
ou: personal
EOF
sudo ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W -f ou-personal.ldif

# Crear unidad organizativa "contabilidad" dentro de "control"
cat <<EOF > ou-contabilidad.ldif
dn: ou=contabilidad,ou=control,dc=vegasoft,dc=local
objectClass: organizationalUnit
ou: contabilidad
EOF
sudo ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W -f ou-contabilidad.ldif

# Crear grupos: usuarios, senior, junior, practicas
cat <<EOF > gr-control.ldif
dn: cn=usuarios,ou=control,dc=vegasoft,dc=local
objectClass: posixGroup
cn: usuarios
gidNumber: 10000

dn: cn=senior,ou=control,dc=vegasoft,dc=local
objectClass: posixGroup
cn: senior
gidNumber: 10001

dn: cn=junior,ou=control,dc=vegasoft,dc=local
objectClass: posixGroup
cn: junior
gidNumber: 10002

dn: cn=practicas,ou=control,dc=vegasoft,dc=local
objectClass: posixGroup
cn: practicas
gidNumber: 10003
EOF
sudo ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W -f gr-control.ldif

# Crear usuarios
cat <<EOF > usr-00.ldif
dn: uid=ceo,ou=control,dc=vegasoft,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ceo
cn: ceo
sn: CEO
uidNumber: 2000
gidNumber: 10000
homeDirectory: /home/ceo
loginShell: /bin/bash
mail: ceo@vegasoft.local
userPassword: {SSHA}Z8qUjC+TxkIzI9CoFL3zSvNMkqwb5JXl

dn: uid=miguelhm,ou=contabilidad,ou=control,dc=vegasoft,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: miguelhm
cn: miguelhm
sn: Miguelhm
uidNumber: 2003
gidNumber: 10000
homeDirectory: /home/miguelhm
loginShell: /bin/bash
mail: miguelhm@vegasoft.local
userPassword: {SSHA}Z8qUjC+TxkIzI9CoFL3zSvNMkqwb5JXl
EOF
sudo ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W -f usr-00.ldif

# Crear carpeta para compartir mediante NFS
sudo mkdir /control_compartido
sudo chown nobody:nogroup /control_compartido
sudo chmod 777 /control_compartido

# Configurar exportación NFS
echo "/control_compartido 192.168.115.101(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo systemctl restart nfs-kernel-server

# Crear carpeta para perfiles móviles
sudo mkdir /movilControl
sudo chown nobody:nogroup /movilControl
sudo chmod 777 /movilControl
