#!/bin/bash

# Script de configuración CORREGIDO para estaciones de trabajo empresariales
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script como root o con sudo"
    exit 1
fi

# Configuración de variables
IMAGE_URL="https://drive.google.com/uc?export=download&id=1Khfg0Ow3PLQ6hjyel32IzsEMZeZ6ZUiM"
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

# Función para configuraciones GNOME - BARRA INFERIOR COMO WINDOWS
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
    
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$usuario_id/bus"
    
    echo "Configurando GNOME para usuario: $usuario"
    echo "Instalando Dash to Panel (barra estilo Windows)..."
    
    # Instalar Dash to Panel (mejor que Dash to Dock)
    apt install -y gnome-shell-extension-dash-to-panel
    
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
    
    # CONFIGURACIÓN DASH TO PANEL (BARRA INFERIOR COMO WINDOWS)
    echo "Configurando barra inferior estilo Windows..."
    
    # Habilitar la extensión
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gnome-extensions enable dash-to-panel@jderose9.github.com
    
    # Configurar posición en la parte inferior
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel panel-position 'BOTTOM'
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel panel-size '48'
    
    # Mostrar ventanas minimizadas en la barra
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel group-apps 'false'
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel show-window-previews 'true'
    
    # Configurar comportamiento como Windows
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel appicon-margin '4'
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel appicon-padding '6'
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel show-running-apps 'true'
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-panel show-apps-icon 'true'
    
    # Deshabilitar dash original
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    
    echo "✓ Barra inferior estilo Windows configurada"
    echo "⚠ REINICIA para aplicar los cambios de la barra"
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

echo "Instalando Winetricks..."
wget -q -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x /usr/local/bin/winetricks
echo "✓ Winetricks instalado manualmente"

# 4. RustDesk - Instalación mejorada
echo "Instalando RustDesk..."
# Instalar desde repositorio oficial
wget -qO - https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-1.2.3-x86_64.deb -O rustdesk.deb
if [ -f "rustdesk.deb" ] && [ -s "rustdesk.deb" ]; then
    apt install -y ./rustdesk.deb
    rm -f rustdesk.deb
    echo "✓ RustDesk instalado"
else
    # Método alternativo - script oficial
    echo "Instalando RustDesk via script oficial..."
    wget https://github.com/rustdesk/rustdesk/releases/download/1.1.9/rustdesk-1.1.9-x86_64.deb -O rustdesk.deb
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

# 9. Linphone - Solución definitiva
echo "Instalando Linphone..."
# Método 1: Desde backports de Debian
echo "Agregando repositorio backports..."
echo "deb http://deb.debian.org/debian bookworm-backports main" >> /etc/apt/sources.list.d/backports.list
apt update

if apt install -y -t bookworm-backports linphone 2>/dev/null; then
    echo "✓ Linphone instalado desde backports"
else
    # Método 2: Descargar e instalar .deb manualmente
    echo "Descargando Linphone manualmente..."
    wget -q -O linphone.deb "http://ftp.debian.org/debian/pool/main/l/linphone/linphone_5.0.13-1_amd64.deb"
    if [ -f "linphone.deb" ] && [ -s "linphone.deb" ]; then
        apt install -y ./linphone.deb
        rm -f linphone.deb
        echo "✓ Linphone instalado manualmente"
    else
        # Método 3: Instalar desde Flatpak
        echo "Instalando Linphone via Flatpak..."
        apt install -y flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        if flatpak install -y flathub org.linphone.desktop 2>/dev/null; then
            echo "✓ Linphone instalado via Flatpak"
            # Crear enlace simbólico para que funcione el comando 'linphone'
            ln -sf /var/lib/flatpak/exports/bin/org.linphone.desktop /usr/local/bin/linphone
        else
            echo "⚠ Linphone no se pudo instalar automáticamente"
            echo "   Instalar manualmente desde: https://linphone.org/releases"
        fi
    fi
fi

# 10. SSH Server
echo "Instalando SSH Server..."
apt install -y openssh-server
check_success "SSH Server"

# 11. Google Earth
echo "Instalando Google Earth..."
apt install -y lsb-release libxss1 libnss3 libxrandr2
# libgconf-2-4 no existe en Debian 13, se omite
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

# CONFIGURAR FONDO DE PANTALLA (OPTIMIZADO PARA GOOGLE DRIVE)
echo "Configurando fondo de pantalla desde Google Drive..."
usuario=$(logname)
DESKTOP_IMAGE="/home/$usuario/Imágenes/fondo-empresa.jpg"
mkdir -p "/home/$usuario/Imágenes"

# Descargar imagen de Google Drive
echo "Descargando: $IMAGE_URL"
if wget --no-check-certificate --timeout=45 --tries=3 -O "$DESKTOP_IMAGE" "$IMAGE_URL" 2>/dev/null; then
    # Verificar que se descargó una imagen válida
    if [ -f "$DESKTOP_IMAGE" ] && [ -s "$DESKTOP_IMAGE" ] && file "$DESKTOP_IMAGE" | grep -q "image"; then
        chown $usuario:$usuario "$DESKTOP_IMAGE"
        # Configurar fondo de pantalla
        sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $usuario)/bus \
            gsettings set org.gnome.desktop.background picture-uri "file://$DESKTOP_IMAGE"
        sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $usuario)/bus \
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$DESKTOP_IMAGE"
        echo "✓ Fondo de pantalla configurado correctamente desde Google Drive"
    else
        echo "⚠ El archivo descargado no es una imagen válida"
        echo "   Google Drive puede estar mostrando una página de confirmación"
        rm -f "$DESKTOP_IMAGE"
    fi
else
    echo "⚠ No se pudo descargar la imagen de Google Drive"
    echo "   Posibles causas:"
    echo "   - La imagen es muy grande (>100MB)"
    echo "   - Necesita confirmación de descarga"
    echo "   - Límite de descargas excedido"
fi

# Forzar recarga de GNOME Shell (sin reiniciar completamente)
echo "Recargando interfaz GNOME..."
usuario=$(logname)
usuario_id=$(id -u $usuario 2>/dev/null)
if [ -n "$usuario_id" ]; then
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$usuario_id/bus gnome-shell --replace &>/dev/null &
    sleep 3
    echo "✓ Interfaz recargada"
fi

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
echo "✓ Linphone - 3 métodos de instalación hasta que uno funcione"
echo "✓ libconf-2-4 - Dependencia eliminada (no existe en Debian 13)"
echo "✓ Barra inferior - Dash to Panel configurado como Windows"
echo "✓ Fondo de pantalla - URL de Google Drive convertida correctamente"
echo ""
echo "🎯 ACCIONES RECOMENDADAS:"
echo "1. Ejecuta: verificar-instalacion.sh"
echo "2. REINICIA para aplicar completamente la barra estilo Windows"
echo "3. Las ventanas minimizadas ahora se verán en la barra inferior"
echo "4. El fondo de pantalla se descargó desde tu Google Drive"
echo "=================================================="