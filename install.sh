#!/bin/bash

# Script para configurar el escritorio XFCE4 en termux

# Colores
Black='\033[0;30m'        # Negro
Red='\033[0;31m'          # Rojo
Green='\033[0;32m'        # Verde
Yellow='\033[0;33m'       # Amarillo
Blue='\033[0;34m'         # Azul
Purple='\033[0;35m'       # Púrpura
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # Blanco
# Negrita
BBlack='\033[1;30m'       # Negro
BRed='\033[1;31m'         # Rojo
BGreen='\033[1;32m'       # Verde
BYellow='\033[1;33m'      # Amarillo
BBlue='\033[1;34m'        # Azul

cd $HOME
apt install figlet
clear
echo -e "$BBlue"
figlet "Hola"

tfx() {
    local text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.03
    done
 echo
}

step() {
    clear
    echo -e "$BBlue"
    tfx "$1"
    echo -e "$Cyan"
}

configurar_x11() {
    clear
    local file="$PREFIX/bin/launch-termux-xfce"
    rm $file
    echo "clear" >> $file
    echo "figlet XFCE4" >> $file
    echo "pulseaudio --start --exit-idle-time=-1" >> $file
    echo "pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> $file
    echo "virgl_test_server_android &" >> $file
    echo "export GALLIUM_DRIVER=virpipe" >> $file
    echo "export MESA_GL_VERSION_OVERRIDE=4.0" >> $file
    echo "export DISPLAY=:3" >> $file
    echo "am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 && sleep 1" >> $file
    echo "termux-x11 :3 -xstartup 'dbus-launch --exit-with-session xfce4-session' && startxfce4" >> $file
    chmod +x $file
    clear
    echo "$BGren ¡Termux:X11 listo!"
}

configurar_vnc() {
    clear
    local file="$PREFIX/bin/launch-termux-xfce"
    rm $file
    echo "vncserver -kill :4" >> $file
    echo "clear" >> $file
    echo "figlet XFCE4" >> $file
    echo "pulseaudio --start --exit-idle-time=-1" >> $file
    echo "pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> $file
    echo "virgl_test_server_android &" >> $file
    echo "export GALLIUM_DRIVER=virpipe" >> $file
    echo "export MESA_GL_VERSION_OVERRIDE=4.0" >> $file
    echo "export DISPLAY=:4" >> $file
    echo "vncserver :4 -xstartup 'dbus-launch --exit-with-session xfce4-session' && startxfce4" >> $file
    chmod +x $file
    clear
    echo "$BGren ¡Servidor VNC listo!"
}

install() {
    if [[ "$instalar" == "y" || "$instalar" == "Y" ]]; then
        clear
        echo -e "$BGreen Iniciando..."
        sleep 3

        # Instalar programas necesarios
        step $"Instalando programas necesarios..."
        yes | pkg install x11-repo
        yes | pkg update
        yes | pkg install dbus
        yes | pkg install termux-am

        # Permiso de almacenamiento
        clear
        echo -e "$BBlue Para continuar es necesario acceder al almacenamiento.\n Conceda el permiso a continuación:\n$Blue"
        termux-setup-storage

        # Instalar sonido y video
        step "Instalando PulseAudio..."
        yes | pkg install pulseaudio
        step "Instalando VirGL..."
        yes | pkg install virglrenderer-android

        # Instalar XFCE4
        step "Instalando XFCE4..."
        yes | pkg install xfce4

        # Configurar entorno
        step "¿Como te gustaría interactuar con el escritorio?"
        echo -e "\n  $BGreen 1.$Green A través de Termux:X11\n  $BGreen 2.$Green A través de un servidor y un cliente VNC\n"
        read -p " > " entorno
        case ${entorno} in
            [1]*)
                step "Instalando termux-x11-nightly"
		        pkg install termux-x11-nightly -y
		        step "Configurando el entorno..."
		        echo "allow-external-apps = true" >> ~/.termux/termux.properties
		        pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
		        configurar_x11
		    ;;
	        [2]*)
		        step "Instalando tigervnc"
		        pkg install tigervnc -y
		        step "Configurando el entorno..."
		        configurar_vnc
		    ;;
        esac

        # Instalar un navegador
        step "¿Que navegador te gustaría instalar?"
        echo -e "\n  $BGreen 1.$Green Firefox\n  $BGreen 2.$Green Netsurf\n"        
        read -p " > " navegador
        case ${navegador} in
            [1]*)
                step "Instalando firefox"
                pkg install firefox -y
            ;;
            [2]*)
                step "Instalando netsurf"
                pkg install netsurf -y
            ;;
        esac

        # Instalar un editor de texto
        step "¿Que editor de texto te gustaría instalar?"
        echo -e "\n  $BGreen 1.$Green Mousepad\n  $BGreen 2.$Green Leafpad\n"        
        read -p " > " navegador
        case ${navegador} in
            [1]*)
                step "Instalando mousepad"
                pkg install mousepad -y
            ;;
            [2]*)
                step "Instalando leafpad"
                pkg install leafpad -y
            ;;
        esac

        # Instalar apps adicionales
        step "¿Quieres completar el escritorio con mejoras y aplicaciones adicionales? (y/n)"
        echo -e "$Green"
        read -p " > " adicionales
        case ${adicionales} in
            [Yy]*)
                step "Instalando paquetes adicionales..."
                apt install -y wget
                rm $PREFIX/etc/apt/sources.list.d/termux-desktop-xfce.list
                wget -P $PREFIX/etc/apt/sources.list.d https://raw.githubusercontent.com/Yisus7u7/termux-desktop-xfce/gh-pages/termux-desktop-xfce.list
                apt install -y xfce4-goodies termux-desktop-xfce breeze-cursor-theme kvantum ttf-microsoft-cascadia audacious pavucontrol-qt geany synaptic
            ;;
        esac

        # Todo listo
        step "Finalizando..."
        sleep 1
        clear
        figlet "OK"
        echo -e "$BGreen¡Todo listo! Ejecute el siguiente comando para iniciar el escritorio"
        echo -e "\n$Green → launch-termux-xfce"

    else
        clear
        figlet "Adios"
    fi
}

read -p "¿Quieres intalar XFCE4 en termux? (y/n): " instalar

install
