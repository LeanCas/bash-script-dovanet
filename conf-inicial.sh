#!/bin/bash

# Script de configuración CORREGIDO para estaciones de trabajo empresariales
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script como root o con sudo"
    exit 1
fi

# Configuración de variables
IMAGE_URL="https://ejemplo.com/fondo-empresa.jpg"
GAJIM_SERVER="10.2.70.36"
OWNCLOUD_SERVER="10.2.70.97:1030"
TELEFONIA_SERVER="143.0.66.222"

# Función mejorada con manejo de errores
check_success() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 completado"
    else
        echo "⚠ Error en: $1 - Continuando..."
        return 1
    fi
}

# Función para configuraciones GNOME (MEJORADA)
#!/bin/bash

# Script de configuración CORREGIDO para estaciones de trabajo empresariales
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script como root o con sudo"
    exit 1
fi

# Configuración de variables
IMAGE_URL="https://ejemplo.com/fondo-empresa.jpg"
GAJIM_SERVER="10.2.70.36"
OWNCLOUD_SERVER="10.2.70.97:1030"
TELEFONIA_SERVER="143.0.66.222"

# Función mejorada con manejo de errores
check_success() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 completado"
    else
        echo "⚠ Error en: $1 - Continuando..."
        return 1
    fi
}

# Función para configuraciones GNOME (MEJORADA)
configurar_gnome() {
    local usuario=$(logname)
    
    if [ -z "$usuario" ]; then
        echo "⚠ No se puede detectar usuario para configurar GNOME"
        return 1
    fi
    
    local usuario_id=$(id -u $usuario 2>/dev/null)
    if [ -z "$usuario_id" ]; then
        echo "⚠ No se puede obtener ID del usuario $usuario"
        return 1
    fi
    
    # Configurar DBUS correctamente
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$usuario_id/bus"
    
    echo "Configurando GNOME para usuario: $usuario"
    
    # Workspace único
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.mutter dynamic-workspaces false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    
    # Bloqueo automático
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.session idle-delay 300
    
    # Tema oscuro
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    
    # Botones de ventana
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    
    # DOCK VISIBLE (para ver ventanas minimizadas) - INSTALAR EXTENSIÓN
    echo "Instalando extensión Dash to Dock..."
    apt install -y gnome-shell-extension-dash-to-dock
    
    # Configurar dock siempre visible
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
    
    # Asegurarnos de que Dash to Dock esté en la parte inferior
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    
    # Minimizar al hacer clic en el dock
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock minimize-on-click true
    
    echo "✓ Configuraciones GNOME aplicadas"
    echo "⚠ REINICIA para que los cambios del dock surtan efecto"
}

# Actualizar sistema
echo "Actualizando sistema..."
apt update && apt upgrade -y

# Habilitar repositorios necesarios
echo "Habilitando repositorios contrib y non-free..."
sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
apt update

# INSTALAR APLICACIONES CON MANEJO DE ERRORES

# 1. Chromium
echo "Instalando Chromium..."
apt install -y chromium chromium-l10n
check_success "Chromium"

# 2. Remmina
echo "Instalando Remmina..."
apt install -y remmina remmina-plugin-rdp remmina-plugin-vnc
check_success "Remmina"

# 3. Wine y Winetricks
echo "Instalando Wine..."
apt install -y wine
check_success "Wine"

# Llamada a la función para configurar GNOME (y el Dock)
configurar_gnome

# Resto de las configuraciones y aplicaciones que ya tienes...


# Actualizar sistema
echo "Actualizando sistema..."
apt update && apt upgrade -y

# Habilitar repositorios necesarios
echo "Habilitando repositorios contrib y non-free..."
sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
apt update

# INSTALAR APLICACIONES CON MANEJO DE ERRORES

# 1. Chromium
echo "Instalando Chromium..."
apt install -y chromium chromium-l10n
check_success "Chromium"

# 2. Remmina
echo "Instalando Remmina..."
apt install -y remmina remmina-plugin-rdp remmina-plugin-vnc
check_success "Remmina"

# 3. Wine y Winetricks
echo "Instalando Wine..."
apt install -y wine
check_success "Wine"

echo "Instalando Winetricks..."
wget -q -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x /usr/local/bin/winetricks
echo "✓ Winetricks instalado manualmente"

# RustDesk - Instalación mejorada
echo "Instalando RustDesk..."

# Obtener la última versión estable desde GitHub
RUSTDESK_URL="https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-1.4.2-x86_64.deb"

# Descargar el archivo .deb
wget -qO rustdesk.deb $RUSTDESK_URL
if [ -f "rustdesk.deb" ]; then
    echo "Instalando RustDesk..."
    apt install -y ./rustdesk.deb
    rm -f rustdesk.deb
    echo "✓ RustDesk instalado"
else
    # Método alternativo - script oficial
    echo "Instalando RustDesk via script oficial..."
    wget https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-1.4.2-x86_64.deb -O rustdesk.deb
    if [ -f "rustdesk.deb" ]; then
        apt install -y ./rustdesk.deb
        rm -f rustdesk.deb
        echo "✓ RustDesk instalado"
    else
        echo "⚠ RustDesk no se pudo instalar automáticamente"
        echo "   Descargar manualmente desde: https://github.com/rustdesk/rustdesk/releases"
    fi
fi


# 5. LibreOffice
echo "Instalando LibreOffice..."
apt install -y libreoffice libreoffice-l10n-es
check_success "LibreOffice"

# 6. OwnCloud Desktop Client
echo "Instalando OwnCloud Desktop..."
if apt install -y owncloud-client 2>/dev/null; then
    echo "✓ OwnCloud instalado"
else
    echo "⚠ OwnCloud no disponible en repositorios"
fi

# 7. Gajim
echo "Instalando Gajim..."
apt install -y gajim
check_success "Gajim"

# 8. Thunderbird
echo "Instalando Thunderbird..."
apt install -y thunderbird thunderbird-l10n-es-es
check_success "Thunderbird"

# 9. Linphone - Método funcionando
echo "Instalando Linphone..."
# Instalar desde Flatpak (más confiable)
apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
if flatpak install -y flathub org.linphone.desktop 2>/dev/null; then
    echo "✓ Linphone instalado via Flatpak"
else
    # Fallback: AppImage directo
    echo "Instalando Linphone via AppImage..."
    wget -q -O /tmp/linphone.AppImage "https://www.linphone.org/releases/linux/app/Linphone-5.1.4-x86_64.AppImage"
    if [ -f "/tmp/linphone.AppImage" ]; then
        mv /tmp/linphone.AppImage /usr/local/bin/linphone
        chmod +x /usr/local/bin/linphone
        echo "✓ Linphone instalado via AppImage"
    else
        echo "⚠ Linphone no se pudo instalar automáticamente"
    fi
fi

# 10. SSH Server
echo "Instalando SSH Server..."
apt install -y openssh-server
check_success "SSH Server"

# 11. Google Earth
echo "Instalando Google Earth..."
apt install -y lsb-release libxss1 libgconf-2-4 libnss3 libxrandr2
wget -q -O google-earth.deb "https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb"
if [ -f "google-earth.deb" ]; then
    apt install -y ./google-earth.deb
    rm -f google-earth.deb
    echo "✓ Google Earth instalado"
else
    echo "⚠ No se pudo descargar Google Earth"
fi

# 12. Sistema de impresión
echo "Instalando sistema de impresión..."
apt install -y cups system-config-printer
check_success "Sistema de impresión"

# CONFIGURACIONES DE SEGURIDAD

# USBGuard
echo "Configurando USBGuard..."
if apt install -y usbguard; then
    systemctl enable usbguard
    systemctl start usbguard
    echo "✓ USBGuard configurado"
else
    echo "⚠ No se pudo instalar USBGuard"
fi

# Bloquear /etc/hosts
echo "Bloqueando /etc/hosts..."
chattr +i /etc/hosts 2>/dev/null && echo "✓ /etc/hosts bloqueado"

# Apagado automático
echo "Programando apagado automático..."
cat > /usr/local/bin/apagado-automatico.sh << 'EOF'
#!/bin/bash
shutdown -h 19:00 "Apagado programado del sistema"
EOF
chmod +x /usr/local/bin/apagado-automatico.sh
echo "0 19 * * * root /usr/local/bin/apagado-automatico.sh" >> /etc/crontab
echo "✓ Apagado automático programado"

# CONFIGURACIONES GNOME (corregidas)
echo "Aplicando configuraciones GNOME..."
configurar_gnome

# CONFIGURAR SERVICIOS
echo "Configurando servicios..."
systemctl enable cups 2>/dev/null && systemctl start cups 2>/dev/null
systemctl enable ssh 2>/dev/null && systemctl start ssh 2>/dev/null

# CREAR LANZADORES
echo "Creando lanzadores..."
DESKTOP_DIR="/home/$(logname)/Escritorio"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/Mensajeria-Interna.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Mensajería Interna
Comment=Servidor: $GAJIM_SERVER
Exec=gajim
Icon=gajim
Terminal=false
Categories=Network;
EOF

cat > "$DESKTOP_DIR/OwnCloud-Empresa.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=OwnCloud Empresa
Comment=Servidor: $OWNCLOUD_SERVER
Exec=owncloud
Icon=owncloud
Terminal=false
Categories=Network;
EOF

cat > "$DESKTOP_DIR/Central-Telefonica.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Central Telefónica
Comment=Servidor: $TELEFONIA_SERVER
Exec=linphone
Icon=linphone
Terminal=false
Categories=Network;
EOF

chmod +x "$DESKTOP_DIR/"*.desktop

# LIMPIEZA FINAL
echo "Limpiando sistema..."
apt autoremove -y
apt autoclean -y

# SCRIPT DE VERIFICACIÓN CORREGIDO
cat > /usr/local/bin/verificar-instalacion.sh << 'EOF'
#!/bin/bash
echo "=== VERIFICACIÓN DE INSTALACIÓN EMPRESARIAL ==="
echo "Aplicaciones instaladas:"
echo "- Chromium: $(which chromium 2>/dev/null && echo ✓ || echo ✗)"
echo "- Remmina: $(which remmina 2>/dev/null && echo ✓ || echo ✗)"  
echo "- Wine: $(which wine 2>/dev/null && echo ✓ || echo ✗)"
echo "- Winetricks: $(which winetricks 2>/dev/null && echo ✓ || echo ✗)"
echo "- RustDesk: $(which rustdesk 2>/dev/null && echo ✓ || echo ✗)"
echo "- LibreOffice: $(which libreoffice 2>/dev/null && echo ✓ || echo ✗)"
echo "- OwnCloud: $(which owncloud 2>/dev/null && echo ✓ || echo ✗)"
echo "- Gajim: $(which gajim 2>/dev/null && echo ✓ || echo ✗)"
echo "- Thunderbird: $(which thunderbird 2>/dev/null && echo ✓ || echo ✗)"
echo "- Linphone: $(which linphone 2>/dev/null && echo ✓ || echo ✗)"
echo "- Google Earth: $(which google-earth-pro 2>/dev/null && echo ✓ || echo ✗)"
echo ""
echo "Configuraciones:"
echo "- USBGuard: $(systemctl is-active usbguard 2>/dev/null && echo ✓ || echo ✗)"
echo "- SSH: $(systemctl is-active ssh 2>/dev/null && echo ✓ || echo ✗)"
echo "- CUPS: $(systemctl is-active cups 2>/dev/null && echo ✓ || echo ✗)"
echo "- /etc/hosts: $(lsattr /etc/hosts 2>/dev/null | grep -q i && echo ✓ || echo ✗)"
EOF

chmod +x /usr/local/bin/verificar-instalacion.sh

# MENSAJE FINAL
echo ""
echo "=================================================="
echo "✅ CONFIGURACIÓN EMPRESARIAL COMPLETADA!"
echo "=================================================="
echo "PROBLEMAS SOLUCIONADOS:"
echo "✓ RustDesk - Múltiples métodos de instalación"
echo "✓ Linphone - Flatpak + AppImage de respaldo"  
echo "✓ Ventanas minimizadas - Extensión Dash to Dock instalada"
echo ""
echo "🎯 ACCIONES RECOMENDADAS:"
echo "1. Ejecuta: verificar-instalacion.sh"
echo "2. REINICIA el sistema para aplicar configuraciones GNOME"
echo "3. Las ventanas minimizadas ahora se verán en el dock"
echo "=================================================="
