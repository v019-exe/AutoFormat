#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo -e "[\033[0;35m\e[1mVOID\e[0m\033[0m][$(date +"%H:%M:%S")]: Ejecuta el script como root"
  exit 1
fi

if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO=$ID
else
  echo "No se pudo detectar la distribución."
  exit 1
fi

color_negro="\033[40m"
color_rojo="\033[41m"
color_verde="\033[42m"
color_amarillo="\033[43m"
color_azul="\033[44m"
color_magenta="\033[45m"
color_cian="\033[46m"
color_blanco="\033[47m"
reset="\033[0m"
negrita="\033[1m"

echo -e "\033[0;35m
            _    __
 _  _____  (_)__/ /
| |/ / _ \/ / _  / 
|___/\___/_/\_,_/  
                   
[*] Github: github.com/v019-exe
[*] Script hecha por v019.exe
[*] OS: $DISTRO
[*] Uso: formatter <distro> <version> <tipo> <usb_device>
\033[0m"

declare -A UBUNTU_VERSIONS=(
  ["14.04.6-desktop"]="https://releases.ubuntu.com/14.04.6/ubuntu-14.04.6-desktop-amd64.iso"
  ["16.04.7-desktop"]="https://releases.ubuntu.com/16.04.7/ubuntu-16.04.6-desktop-i386.iso"
  ["18.04.6-desktop"]="https://releases.ubuntu.com/18.04.6/ubuntu-18.04.6-desktop-amd64.iso"
  ["20.04.6-desktop"]="https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-desktop-amd64.iso"
  ["22.04.5-desktop"]="https://releases.ubuntu.com/22.04.5/ubuntu-22.04.5-desktop-amd64.iso"
  ["14.04.6-server"]="https://releases.ubuntu.com/14.04.6/ubuntu-14.04.6-server-amd64.iso"
  ["16.04.7-server"]="https://releases.ubuntu.com/16.04.7/ubuntu-16.04.7-server-amd64.iso"
  ["18.04.6-server"]="https://releases.ubuntu.com/18.04.6/ubuntu-18.04.6-server-amd64.iso"
  ["20.04.6-server"]="https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso"
  ["22.04.5-server"]="https://releases.ubuntu.com/22.04.5/ubuntu-22.04.5-live-server-amd64.iso"
)

declare -A DEBIAN_VERSIONS=(
  ["10.13-desktop"]="https://cdimage.debian.org/cdimage/archive/10.13.0/amd64/iso-dvd/debian-10.13.0-amd64-DVD-1.iso"
  ["11.7-desktop"]="https://cdimage.debian.org/cdimage/archive/11.7.0/amd64/iso-dvd/debian-11.7.0-amd64-DVD-1.iso"
  ["12.2-desktop"]="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.2.0-amd64-DVD-1.iso"
  ["10.13-server"]="https://cdimage.debian.org/cdimage/archive/10.13.0/amd64/iso-cd/debian-10.13.0-amd64-netinst.iso"
  ["11.7-server"]="https://cdimage.debian.org/cdimage/archive/11.7.0/amd64/iso-cd/debian-11.7.0-amd64-netinst.iso"
  ["12.2-server"]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"
)

declare -A ARCH_VERSIONS=(
  ["latest"]="https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
)

declare -A FEDORA_VERSIONS=(
  ["37-desktop"]="https://download.fedoraproject.org/pub/fedora/linux/releases/37/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-37-1.7.iso"
  ["38-desktop"]="https://download.fedoraproject.org/pub/fedora/linux/releases/38/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-38-1.6.iso"
  ["37-server"]="https://download.fedoraproject.org/pub/fedora/linux/releases/37/Server/x86_64/iso/Fedora-Server-dvd-x86_64-37-1.7.iso"
  ["38-server"]="https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-dvd-x86_64-38-1.6.iso"
)

download_distro() {
  local -n distro_versions=$1
  local version_key="$2"
  local distro_name="$3"


  if [[ -v "distro_versions[$version_key]" ]]; then
    echo -e "[VOID][$(date +"%H:%M:%S")]: Descargando $distro_name $version_key"
    wget -O "${distro_name}-${version_key}.iso" "${distro_versions[$version_key]}"
    if [ $? -eq 0 ]; then
      echo -e "[VOID][$(date +"%H:%M:%S")]: Descargado con éxito"
    else
      echo -e "[VOID][$(date +"%H:%M:%S")]: Fallo en la descarga de $distro_name $version_key, verifica tu conexión"
      exit 1
    fi
  else
    echo -e "[VOID][$(date +"%H:%M:%S")]: La versión $version_key no está disponible para $distro_name."
    exit 1
  fi
}

create_bootable_usb() {
  local iso_file=$1
  local usb_device=$2

  echo -e "[VOID][$(date +"%H:%M:%S")]: ¡ADVERTENCIA! Esto formateará $usb_device y escribirá $iso_file en él."
  echo -ne "¿Deseas continuar? (sí/no): "
  read confirmation
  if [[ $confirmation != "sí" ]]; then
    echo "[VOID][$(date +"%H:%M:%S")]: Operación cancelada."
    exit 1
  fi

  echo -e "[VOID][$(date +"%H:%M:%S")]: Formateando y creando USB booteable en $usb_device..."
  sudo umount "$usb_device"* || true
  sudo dd if="$iso_file" of="$usb_device" bs=4M status=progress oflag=sync
  sync
  echo -e "[VOID][$(date +"%H:%M:%S")]: Creación de USB booteable completa."
}

os=$1
version=$2
type=$3
usb_device=$4

if [[ -z $os || -z $version || -z $type ]]; then
  echo -e "[VOID][$(date +"%H:%M:%S")]: Uso: formatter <distro> <version> <tipo> <usb_device>"
  exit 1
fi

case $os in
  ubuntu)
    download_distro UBUNTU_VERSIONS "$version-$type" "Ubuntu"
    ;;
  debian)
    download_distro DEBIAN_VERSIONS "$version-$type" "Debian"
    ;;
  arch)
    download_distro ARCH_VERSIONS "latest" "Arch"
    ;;
  fedora)
    download_distro FEDORA_VERSIONS "$version-$type" "Fedora"
    ;;
  *)
    echo -e "[VOID][$(date +"%H:%M:%S")]: OS no soportado, saliendo."
    exit 1
    ;;
esac

iso_file="${os}-${version}-${type}.iso"
if [[ -n $usb_device ]]; then
  create_bootable_usb "$iso_file" "$usb_device"
fi
