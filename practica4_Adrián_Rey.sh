#!/bin/bash
function show_ayuda() {
echo "USO: $0 fichero"
echo "DESCRIPCIÓN: Este script instala, desinstala o muestra el estado de paquetes de software según un fichero"
}
if [ $# -eq 0 ]; then
show_ayuda
exit 1
fi
FICHERO=$1
if [ ! -f $FICHERO ] || [ ! -r $FICHERO ]; then
echo "El fichero $FICHERO no existe o no se puede leer"
exit 2
fi
if [ $EUID -ne 0 ]; then
echo "Este script debe ejecutarse como root"
exit 3
fi
while IFS=: read -r packagename action; do
INSTALADO=$(whereis $packagename | grep bin | wc -l)
case $action in
remove|r)
if [ $INSTALADO -gt 0 ]; then
apt remove -y $packagename
apt purge -y $packagename
echo "El paquete $packagename ha sido desinstalado"
else
echo "El paquete $packagename no está instalado"
fi
;;
install|i)
if [ $INSTALADO -eq 0 ]; then
apt install -y $packagename
echo "El paquete $packagename ha sido instalado"
else
apt install -y $packagename
echo "El paquete $packagename ha sido actualizado"
# Si pones install a un paquete ya instalado este se actualiza en vez que instalar
fi
;;
status|s)
if [ $INSTALADO -gt 0 ]; then
echo "El paquete $packagename está instalado"
else
echo "El paquete $packagename no está instalado"
fi
;;
*)
echo "La acción $action no es válida para el paquete $packagename"
;;
esac
done < $FICHERO
echo "El script ha terminado de ejecutarse"
