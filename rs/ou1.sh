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
dn: ou=$nombre_ou,dc=vegasoft,dc=local
objectClass: organizationalUnit
ou: $nombre_ou
EOF
ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W -f ou-$nombre_ou.ldif
read -p "¿Quieres crear otra unidad organizativa de 1º nivel?(y/n)" resp
if [ $resp = "y" ]
then
nombre_ou
elif [ $resp = "n" ]
then
./examen.sh
else
./examen.sh
fi
}
