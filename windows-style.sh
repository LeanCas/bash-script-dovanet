#!/bin/bash

# Script para personalizar Debian con apariencia estilo Windows
# Debe ejecutarse como usuario normal (no root)

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en Debian
if ! grep -q "Debian" /etc/os-release; then
    print_error "Este script está diseñado para Debian"
    exit 1
fi

print_message "Iniciando personalización de Debian con estilo Windows..."

# Actualizar sistema
print_message "Actualizando sistema..."
sudo apt update
sudo apt upgrade -y

# Instalar componentes básicos del escritorio (si no están instalados)
print_message "Instalando componentes del escritorio..."
sudo apt install -y \
    task-gnome-desktop \
    gnome-shell \
    gnome-shell-extensions \
    gnome-tweaks \
    gnome-shell-extension-desktop-icons-ng \
    dconf-editor \
    arc-theme \
    papirus-icon-theme \
    fonts-noto \
    file-roller \
    nautilus \
    gedit

# Instalar tema similar a Windows
print_message "Instalando temas y iconos..."
sudo apt install -y \
    materia-gtk-theme \
    numix-icon-theme \
    adwaita-icon-theme

# Configurar GNOME Shell extensions
print_message "Configurando extensiones de GNOME..."

# Crear directorio de extensiones si no existe
mkdir -p ~/.local/share/gnome-shell/extensions

# Instalar extensiones útiles para estilo Windows
print_message "Instalando extensiones adicionales..."

# Instalar dash-to-panel (similar a la barra de tareas de Windows)
if [ ! -d ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com ]; then
    git clone https://github.com/home-sweet-gnome/dash-to-panel.git /tmp/dash-to-panel
    mkdir -p ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
    cp -r /tmp/dash-to-panel/* ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/
fi

# Instalar desktop-icons-ng (iconos en el escritorio)
sudo apt install -y gnome-shell-extension-desktop-icons-ng

# Configurar temas y apariencia
print_message "Configurando temas y apariencia..."

# Configurar GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'Materia-light-compact'
gsettings set org.gnome.desktop.wm.preferences theme 'Materia-light-compact'
gsettings set org.gnome.shell.extensions.user-theme name 'Materia-light-compact'

# Configurar icon theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'

# Configurar fuentes
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Noto Sans Bold 10'

# Configurar comportamiento de ventanas al estilo Windows
print_message "Configurando comportamiento de ventanas..."

# Botones de ventana (minimizar, maximizar, cerrar)
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Mostrar iconos en botones
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Habilitar minimizar al hacer clic
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

# Configurar dash-to-panel (si está disponible)
if gnome-extensions list | grep -q "dash-to-panel"; then
    print_message "Configurando dash-to-panel..."
    gsettings set org.gnome.shell.extensions.dash-to-panel panel-size 40
    gsettings set org.gnome.shell.extensions.dash-to-panel location-clock 'STATUSLEFT'
    gsettings set org.gnome.shell.extensions.dash-to-panel show-show-apps-button true
fi

# Configurar iconos del escritorio
print_message "Configurando iconos del escritorio..."

# Habilitar iconos en el escritorio
gsettings set org.gnome.shell.extensions.ding show-home true
gsettings set org.gnome.shell.extensions.ding show-trash true
gsettings set org.gnome.shell.extensions.ding show-volumes true
gsettings set org.gnome.shell.extensions.ding show-drop-shadow true
gsettings set org.gnome.shell.extensions.ding icon-size 'small'

# Configurar Nautilus (gestor de archivos)
print_message "Configurando Nautilus..."

gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
gsettings set org.gnome.nautilus.preferences show-hidden-files false
gsettings set org.gnome.nautilus.preferences show-create-link true
gsettings set org.gnome.nautilus.list-view use-tree-view true

# Configurar comportamiento del sistema
print_message "Configurando comportamiento del sistema..."

# Habilitar ubicación de la barra de tareas (abajo)
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Mostrar porcentaje de batería
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Configurar atajos de teclado similares a Windows
print_message "Configurando atajos de teclado..."

gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.shell.keybindings switch-to-application-1 "['<Super>1']"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "['<Super>2']"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "['<Super>3']"

# Configurar fondo de pantalla (puedes cambiar la URL por una de tu preferencia)
print_message "Configurando fondo de pantalla..."
mkdir -p ~/Imágenes/Wallpapers
cd ~/Imágenes/Wallpapers

# Descargar un fondo de pantalla estilo Windows (opcional)
if ! command -v wget &> /dev/null; then
    sudo apt install -y wget
fi

# Descargar un fondo azul simple similar a Windows
wget -O windows-style-wallpaper.jpg "https://via.placeholder.com/1920x1080/0078D7/FFFFFF?text=Windows+Style+Debian" || true

# Establecer fondo de pantalla
if [ -f ~/Imágenes/Wallpapers/windows-style-wallpaper.jpg ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Imágenes/Wallpapers/windows-style-wallpaper.jpg"
fi

# Crear accesos directos comunes en el escritorio
print_message "Creando accesos directos en el escritorio..."

mkdir -p ~/Escritorio

# Crear lanzador para terminal
cat > ~/Escritorio/terminal.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Terminal de sistema
Exec=gnome-terminal
Icon=utilities-terminal
Terminal=false
Categories=System;
EOF

# Crear lanzador para navegador web
cat > ~/Escritorio/navegador-web.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Navegador Web
Comment=Navegador web
Exec=xdg-open https://www.google.com
Icon=web-browser
Terminal=false
Categories=Network;
EOF

# Crear lanzador para gestor de archivos
cat > ~/Escritorio/archivos.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Archivos
Comment=Gestor de archivos
Exec=nautilus
Icon=system-file-manager
Terminal=false
Categories=System;
EOF

# Hacer ejecutables los lanzadores
chmod +x ~/Escritorio/*.desktop

# Configuración final
print_message "Aplicando configuración final..."

# Habilitar extensiones
gnome-extensions enable desktop-icons@csoriano
gnome-extensions enable dash-to-panel@jderose9.github.com 2>/dev/null || true

# Reiniciar GNOME Shell (sin cerrar sesión)
print_message "Reiniciando GNOME Shell..."
if command -v gnome-shell &> /dev/null; then
    gnome-shell --replace &
    disown
fi

print_message "¡Configuración completada!"
print_warning "Es posible que necesites reiniciar la sesión para que todos los cambios surtan efecto."
print_message "Características configuradas:"
echo "  ✓ Botones de ventana (minimizar, maximizar, cerrar)"
echo "  ✓ Iconos en el escritorio"
echo "  ✓ Barra de tareas en la parte inferior"
echo "  ✓ Tema similar a Windows"
echo "  ✓ Atajos de teclado estilo Windows"
echo "  ✓ Gestor de archivos configurado"
echo ""
print_message "Puedes personalizar más ajustes con: gnome-tweaks"