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
  netplan
elif [ $opcion = "2" ]
then
  ou1
elif [ $opcion = "3" ]
then
  ou2
elif [ $opcion = "4" ]
then
  gr
elif [ $opcion = "5" ]
then
  usr
elif [ $opcion = "6" ]
then
  nfs
elif [ $opcion = "7" ]
then
  movil
elif [ $opcion = "8" ]
then
  echo "Saliendo del programa..."
else
  clear
  menu
fi
}

netplan() {
    clear
    echo "Ejecutando netplan..."
    ./rs/netplan.sh
}

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
