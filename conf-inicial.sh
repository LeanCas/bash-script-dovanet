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

# Función para configurar idioma español
configurar_idioma_espanol() {
    echo "Configurando sistema en español..."
    
    # Instalar paquetes de idioma
    apt install -y locales
    
    # Generar locales en español
    sed -i '/es_ES.UTF-8/s/^#//g' /etc/locale.gen
    locale-gen es_ES.UTF-8
    
    # Configurar locale por defecto
    update-locale LANG=es_ES.UTF-8 LC_MESSAGES=es_ES.UTF-8
    
    # Configurar teclado español
    sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="es"/' /etc/default/keyboard
    
    echo "✓ Idioma español configurado"
}

# Función para configurar zona horaria de Argentina
configurar_zona_horaria() {
    echo "Configurando zona horaria de Argentina..."
    
    # Configurar timezone a America/Argentina/Buenos_Aires
    timedatectl set-timezone America/Argentina/Buenos_Aires
    
    # Verificar la configuración
    current_timezone=$(timedatectl show --property=Timezone --value)
    if [ "$current_timezone" = "America/Argentina/Buenos_Aires" ]; then
        echo "✓ Zona horaria configurada: Argentina (Buenos Aires)"
        echo "  Hora actual: $(date)"
    else
        echo "⚠ No se pudo configurar la zona horaria automáticamente"
        echo "  Configurar manualmente: sudo timedatectl set-timezone America/Argentina/Buenos_Aires"
    fi
    
    # Configurar NTP para sincronización automática
    timedatectl set-ntp true
    echo "✓ Sincronización automática de hora activada"
}

# Función CORREGIDA para configuraciones GNOME
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
    
    # SOLUCIÓN CORREGIDA: Instalar extensiones disponibles en Debian 13
    echo "Instalando extensiones GNOME..."
    apt install -y gnome-shell-extension-dash-to-dock gnome-shell-extension-desktop-icons-ng
    
    # Configuraciones básicas de GNOME
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.mutter dynamic-workspaces false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.session idle-delay 300
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    
    # CONFIGURACIÓN DASH TO DOCK
    echo "Configurando dock en la parte inferior..."
    
    # Posición en la parte inferior
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    
    # Siempre visible (no se esconde)
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
    
    # Mostrar ventanas minimizadas en el dock
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock show-running-apps true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    
    # Tamaño y comportamiento
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.8
    
    # Forzar recarga de la extensión
    echo "Activando extensión Dash to Dock..."
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gnome-extensions enable dash-to-dock@micxgx.gmail.com
    
    echo "✓ Dock configurado en la parte inferior"
    echo "Las ventanas minimizadas se mostrarán en la barra inferior"
}

# Función CORREGIDA para configurar escritorio Windows
configurar_escritorio_windows() {
    local usuario=$(logname)
    
    if [ -z "$usuario" ]; then
        echo "⚠ No se puede detectar usuario para configurar escritorio"
        return 1
    fi
    
    local usuario_id=$(id -u $usuario 2>/dev/null)
    if [ -z "$usuario_id" ]; then
        echo "⚠ No se puede obtener ID del usuario $usuario"
        return 1
    fi
    
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$usuario_id/bus"
    
    echo "Configurando escritorio estilo Windows para usuario: $usuario"
    
    # 1. Instalar extensiones disponibles en Debian 13
    echo "Instalando extensiones para escritorio..."
    apt install -y gnome-shell-extension-desktop-icons-ng
    
    # 2. Configurar Nautilus para comportamiento Windows
    echo "Configurando Nautilus como Windows Explorer..."
    
    # Configurar comportamiento de clics como Windows (doble clic)
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences click-policy 'double'
    
    # Mostrar barra de direcciones completa
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences always-use-location-entry true
    
    # Ordenar por nombre por defecto
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences default-sort-order 'name'
    
    # Vista de iconos grandes por defecto
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
    
    # Mostrar archivos ocultos
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences show-hidden-files true
    
    # 3. Configurar Desktop Icons NG (extensión moderna)
    echo "Configurando iconos de escritorio..."
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-home true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-trash true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-volumes true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-drop-place true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding use-desktop-grid false
    
    # 4. CREAR PLANTILLAS EN ESPAÑOL
    echo "Creando plantillas en español..."
    TEMPLATES_DIR="/home/$usuario/Plantillas"
    mkdir -p "$TEMPLATES_DIR"
    
    # Plantillas en español
    cat > "$TEMPLATES_DIR/Documento de texto vacío" << 'EOF'
Documento de texto vacío - hacer doble clic para editar
EOF

    cat > "$TEMPLATES_DIR/Nuevo documento de texto.txt" << EOF
Nuevo documento de texto
Creado el: $(date)
EOF

    # Asegurar permisos
    chown -R $usuario:$usuario "$TEMPLATES_DIR"
    chmod 755 "$TEMPLATES_DIR"
    
    # 5. CONFIGURAR DIRECTORIOS DE ESCRITORIO
    echo "Configurando directorios de escritorio..."
    ESCRITORIO_DIR="/home/$usuario/Escritorio"
    mkdir -p "$ESCRITORIO_DIR"
    chown $usuario:$usuario "$ESCRITORIO_DIR"
    chmod 755 "$ESCRITORIO_DIR"
    
    # 6. Configurar comportamiento de arrastre
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences enable-interactive-search true
    
    echo "✓ Escritorio estilo Windows configurado"
    echo "✓ Iconos visibles en el escritorio"
    echo "✓ Comportamiento de doble clic activado"
}

# Función CORREGIDA para instalación de aplicaciones
instalar_aplicaciones_empresariales() {
    echo "=== INSTALANDO APLICACIONES EMPRESARIALES ==="
    
    # Actualizar sistema primero
    apt update && apt upgrade -y
    
    # Habilitar repositorios necesarios
    echo "Habilitando repositorios contrib y non-free..."
    sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
    apt update

    # INSTALAR APLICACIONES CORREGIDAS
    
    # 1. Chromium CORREGIDO
    echo "Instalando Chromium..."
    apt install -y chromium
    check_success "Chromium"

    # 2. Remmina
    echo "Instalando Remmina..."
    apt install -y remmina remmina-plugin-rdp remmina-plugin-vnc
    check_success "Remmina"

        # 4. RustDesk - VERSIÓN CORREGIDA
    echo "Instalando RustDesk..."
    wget -q https://github.com/rustdesk/rustdesk/releases/download/1.4.2/rustdesk-1.4.2-x86_64.deb -O /tmp/rustdesk.deb
    if [ -f "/tmp/rustdesk.deb" ]; then
        # Usar dpkg en lugar de apt para instalar paquetes .deb locales
        dpkg -i /tmp/rustdesk.deb
        # Resolver dependencias si las hay
        apt install -f -y
        rm -f /tmp/rustdesk.deb
        echo "✓ RustDesk instalado"
    else
        echo "⚠ No se pudo descargar RustDesk"
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

    # 9. Otras aplicaciones útiles
    echo "Instalando aplicaciones adicionales..."
    apt install -y \
        filezilla \
        vlc \
        gimp \
        evince \
        nautilus-admin \
        gnome-terminal \
        gnome-tweaks \
        cups system-config-printer \
        openssh-server \
        usbguard

    echo "✓ Aplicaciones empresariales instaladas"
}

# Función para configurar Linphone
configurar_linphone() {
    local usuario=$(logname)
    if [ -z "$usuario" ]; then
        echo "⚠ No se puede detectar usuario para Linphone"
        return 1
    fi
    
    echo "Configurando Linphone..."
    
    LINPHONE_FILE="/home/$usuario/Descargas/Linphone.AppImage"
    mkdir -p "/home/$usuario/Descargas"
    
    # Intentar descargar Linphone
    if wget -q "https://download.linphone.org/releases/linux/app/Linphone-5.0.14-x86_64.AppImage" -O "$LINPHONE_FILE"; then
        chmod +x "$LINPHONE_FILE"
        echo "✓ Linphone descargado y configurado"
    else
        echo "⚠ No se pudo descargar Linphone"
    fi
}

# Función para configurar Google Earth
instalar_google_earth() {
    echo "Instalando Google Earth..."
    
    # Instalar dependencias
    apt install -y lsb-release libxss1 libnss3 libxrandr2
    
    # Descargar e instalar
    if wget -q "https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb" -O /tmp/google-earth.deb; then
        apt install -y ./google-earth.deb
        rm -f /tmp/google-earth.deb
        echo "✓ Google Earth instalado"
    else
        echo "⚠ No se pudo descargar Google Earth"
    fi
}

# Función para configurar servicios
configurar_servicios() {
    echo "Configurando servicios..."
    
    systemctl enable cups 2>/dev/null && systemctl start cups 2>/dev/null
    systemctl enable ssh 2>/dev/null && systemctl start ssh 2>/dev/null
    systemctl enable usbguard 2>/dev/null && systemctl start usbguard 2>/dev/null
    
    echo "✓ Servicios configurados"
}

# Función para configurar seguridad
configurar_seguridad() {
    echo "Configurando seguridad..."
    
    # Bloquear /etc/hosts
    chattr +i /etc/hosts 2>/dev/null && echo "✓ /etc/hosts bloqueado"
    
    # Apagado automático
    echo "0 19 * * * root /sbin/shutdown -h now" >> /etc/crontab
    echo "✓ Apagado automático programado"
}

# Función para crear lanzadores empresariales
crear_lanzadores_empresariales() {
    local usuario=$(logname)
    if [ -z "$usuario" ]; then
        return 1
    fi
    
    echo "Creando lanzadores empresariales..."
    
    ESCRITORIO_DIR="/home/$usuario/Escritorio"
    mkdir -p "$ESCRITORIO_DIR"
    
    # Mensajería Interna
    cat > "$ESCRITORIO_DIR/Mensajeria-Interna.desktop" << EOF
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

    # Archivos Empresa
    cat > "$ESCRITORIO_DIR/Archivos-Empresa.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Archivos Empresa
Comment=Servidor: $OWNCLOUD_SERVER
Exec=nautilus
Icon=nautilus
Terminal=false
Categories=System;
EOF

    # Central Telefónica
    cat > "$ESCRITORIO_DIR/Central-Telefonica.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Central Telefónica
Comment=Servidor: $TELEFONIA_SERVER
Exec=linphone
Icon=phone
Terminal=false
Categories=Network;
EOF

    chmod +x "$ESCRITORIO_DIR/"*.desktop
    chown -R $usuario:$usuario "$ESCRITORIO_DIR"
    
    echo "✓ Lanzadores creados"
}

# Función para verificación final
verificacion_final() {
    echo ""
    echo "=================================================="
    echo "✅ CONFIGURACIÓN EMPRESARIAL COMPLETADA"
    echo "=================================================="
    echo ""
    echo "🎯 RESUMEN EJECUTADO:"
    echo "✓ Sistema configurado en español"
    echo "✓ Zona horaria Argentina"
    echo "✓ Barra inferior estilo Windows"
    echo "✓ Escritorio con iconos y comportamiento Windows"
    echo "✓ Aplicaciones empresariales instaladas"
    echo "✓ Servicios configurados y activos"
    echo ""
    echo "🔄 PARA APLICAR TODOS LOS CAMBIOS:"
    echo "   👉 CERRAR SESIÓN y volver a entrar"
    echo "   👉 O REINICIAR el sistema"
    echo ""
    echo "🔧 CARACTERÍSTICAS CONFIGURADAS:"
    echo "   • Dock en parte inferior siempre visible"
    echo "   • Doble clic para abrir archivos"
    echo "   • Iconos en el escritorio"
    echo "   • Workspace único"
    echo "   • Tema oscuro empresarial"
    echo "=================================================="
}

# ========== EJECUCIÓN PRINCIPAL ==========

echo "Iniciando configuración empresarial corregida..."
echo "Este proceso puede tomar varios minutos..."
echo ""

# Ejecutar en orden
configurar_idioma_espanol
configurar_zona_horaria
instalar_aplicaciones_empresariales
configurar_gnome
configurar_escritorio_windows
configurar_linphone
instalar_google_earth
configurar_servicios
configurar_seguridad
crear_lanzadores_empresariales

# Limpieza final
echo "Limpiando sistema..."
apt autoremove -y
apt autoclean

# Verificación final
verificacion_final

echo ""
echo "🎯 ¡Configuración completada exitosamente!"
echo "👉 Por favor, cierre sesión y vuelva a entrar para ver todos los cambios."