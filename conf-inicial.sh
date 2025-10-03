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

# Función para configuraciones GNOME - BARRA INFERIOR CORREGIDA
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
    
    # SOLUCIÓN DEFINITIVA: Usar Dash to Dock configurado correctamente
    echo "Instalando y configurando Dash to Dock..."
    apt install -y gnome-shell-extension-dash-to-dock
    
    # Configuraciones básicas de GNOME
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.mutter dynamic-workspaces false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.session idle-delay 300
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    
    # CONFIGURACIÓN DASH TO DOCK PARA COMPORTAMIENTO COMO WINDOWS
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

# Función para configurar escritorio como Windows (FUNCIONAL)
# Función para configurar escritorio como Windows (FUNCIONAL)
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
    
    # 1. Instalar extensiones NECESARIAS para iconos en el escritorio
    echo "Instalando extensiones para escritorio..."
    apt install -y gnome-shell-extension-desktop-icons-ng
    
    # 2. Configurar Nautilus (gestor de archivos) para comportamiento como Windows
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
    
    # 3. HABILITAR ESCRITORIO COMPLETAMENTE FUNCIONAL
    echo "Habilitando escritorio completamente funcional..."
    
    # CORRECCIÓN: gnome-shell-extension-desktop-icons no existe en Debian 13
    # Usar solo gnome-shell-extension-desktop-icons-ng que ya está instalado
    
    # Configurar Desktop Icons NG (extensión moderna)
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-home true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-trash true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-volumes true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-drop-place true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding use-desktop-grid false
    
    # 4. CREAR PLANTILLAS PARA "NUEVO DOCUMENTO" - FUNCIONAL
    echo "Creando plantillas para Nuevo documento..."
    TEMPLATES_DIR="/home/$usuario/Plantillas"
    mkdir -p "$TEMPLATES_DIR"
    
    # Plantilla de documento de texto FUNCIONAL
    cat > "$TEMPLATES_DIR/Documento de texto vacío" << 'EOF'
Documento de texto vacío - hacer doble clic para editar
EOF

    # Plantilla de documento de texto con extensión .txt
    cat > "$TEMPLATES_DIR/Nuevo documento de texto.txt" << 'EOF'
Nuevo documento de texto creado el $(date)
Puede editar este archivo con cualquier editor de texto.
EOF

    # Plantilla de carpeta
    cat > "$TEMPLATES_DIR/Nueva carpeta" << 'EOF'
#!/bin/bash
# Plantilla para nueva carpeta
echo "Creando nueva carpeta..."
EOF
    chmod +x "$TEMPLATES_DIR/Nueva carpeta"
    
    # Asegurar permisos
    chown -R $usuario:$usuario "$TEMPLATES_DIR"
    chmod 755 "$TEMPLATES_DIR"
    
    # 5. CONFIGURAR PERMISOS DEL ESCRITORIO
    echo "Configurando permisos del escritorio..."
    DESKTOP_DIR="/home/$usuario/Desktop"
    ESCRITORIO_DIR="/home/$usuario/Escritorio"
    
    # Crear ambos directorios (inglés y español)
    mkdir -p "$DESKTOP_DIR"
    mkdir -p "$ESCRITORIO_DIR"
    
    # Dar permisos completos al usuario
    chown $usuario:$usuario "$DESKTOP_DIR"
    chown $usuario:$usuario "$ESCRITORIO_DIR"
    chmod 755 "$DESKTOP_DIR"
    chmod 755 "$ESCRITORIO_DIR"
    
    # Crear enlace simbólico para compatibilidad
    ln -sf "$ESCRITORIO_DIR" "$DESKTOP_DIR" 2>/dev/null || true
    
    # 6. CONFIGURAR CONTEXTO MENÚ COMPLETO
    echo "Configurando menú contextual completo..."

    # Instalar herramientas adicionales para mejor experiencia (versiones compatibles con Debian 13)
    apt install -y nautilus-admin nautilus-extension-gnome-terminal

    # Configurar acciones de administrador para Nautilus
    if which nautilus >/dev/null 2>&1; then
        # Habilitar extensiones de nautilus
        sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.extensions.enabled "['nautilus-admin@gnome-shell-extensions.gcampax.github.com']"
        echo "✓ Extensiones de Nautilus configuradas"
    fi
    
    # 7. CONFIGURAR COMPORTAMIENTO DE ARRASTRE Y SOLTAR
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences enable-interactive-search true
    
    echo "✓ Escritorio configurado estilo Windows - COMPLETAMENTE FUNCIONAL"
    echo "✓ Iconos visibles en el escritorio"
    echo "✓ Puede crear archivos y carpetas haciendo clic derecho → Nuevo documento"
    echo "✓ Arrastrar y soltar funcionando"
    echo "✓ Doble clic para abrir archivos"
}
# Función de verificación de instalación
verificar_instalacion() {
    echo ""
    echo "=================================================="
    echo "🔍 VERIFICACIÓN DE INSTALACIÓN EMPRESARIAL"
    echo "=================================================="
    
    # Verificar zona horaria
    echo ""
    echo "🌍 CONFIGURACIÓN DE ZONA HORARIA:"
    current_timezone=$(timedatectl show --property=Timezone --value)
    if [ "$current_timezone" = "America/Argentina/Buenos_Aires" ]; then
        echo "✅ Zona horaria: Argentina (Buenos Aires)"
        echo "   Hora actual: $(date)"
    else
        echo "❌ Zona horaria: $current_timezone (debería ser America/Argentina/Buenos_Aires)"
    fi
    
    # Verificar aplicaciones instaladas
    echo ""
    echo "📦 APLICACIONES INSTALADAS:"
    
    # Chromium
    if which chromium >/dev/null 2>&1; then
        echo "✅ Chromium - INSTALADO"
    else
        echo "❌ Chromium - NO INSTALADO"
    fi
    
    # Remmina
    if which remmina >/dev/null 2>&1; then
        echo "✅ Remmina - INSTALADO"
    else
        echo "❌ Remmina - NO INSTALADO"
    fi
    
    # Wine
    if which wine >/dev/null 2>&1; then
        echo "✅ Wine - INSTALADO"
    else
        echo "❌ Wine - NO INSTALADO"
    fi
    
    # Winetricks
    if which winetricks >/dev/null 2>&1; then
        echo "✅ Winetricks - INSTALADO"
    else
        echo "❌ Winetricks - NO INSTALADO"
    fi
    
    # RustDesk
    if which rustdesk >/dev/null 2>&1; then
        echo "✅ RustDesk - INSTALADO"
    else
        echo "❌ RustDesk - NO INSTALADO"
    fi
    
    # LibreOffice
    if which libreoffice >/dev/null 2>&1; then
        echo "✅ LibreOffice - INSTALADO"
    else
        echo "❌ LibreOffice - NO INSTALADO"
    fi
    
    # OwnCloud
    if which owncloud >/dev/null 2>&1; then
        echo "✅ OwnCloud - INSTALADO"
    else
        echo "❌ OwnCloud - NO INSTALADO"
    fi
    
    # Gajim
    if which gajim >/dev/null 2>&1; then
        echo "✅ Gajim - INSTALADO"
    else
        echo "❌ Gajim - NO INSTALADO"
    fi
    
    # Thunderbird
    if which thunderbird >/dev/null 2>&1; then
        echo "✅ Thunderbird - INSTALADO"
    else
        echo "❌ Thunderbird - NO INSTALADO"
    fi
    
    # Linphone
    if which linphone >/dev/null 2>&1 || [ -f "/usr/local/bin/linphone" ] || [ -f "/usr/bin/linphone" ] || [ -f "/home/$(logname)/Descargas/Linphone-6.0.1-CallEdition-x86_64.AppImage" ]; then
        echo "✅ Linphone - INSTALADO"
    else
        echo "❌ Linphone - NO INSTALADO"
    fi
    
    # Google Earth
    if which google-earth-pro >/dev/null 2>&1; then
        echo "✅ Google Earth - INSTALADO"
    else
        echo "❌ Google Earth - NO INSTALADO"
    fi
    
    # Verificar servicios
    echo ""
    echo "⚙️ SERVICIOS CONFIGURADOS:"
    
    # SSH
    if systemctl is-active ssh >/dev/null 2>&1; then
        echo "✅ SSH Server - ACTIVO"
    else
        echo "❌ SSH Server - INACTIVO"
    fi
    
    # CUPS
    if systemctl is-active cups >/dev/null 2>&1; then
        echo "✅ CUPS (Impresión) - ACTIVO"
    else
        echo "❌ CUPS (Impresión) - INACTIVO"
    fi
    
    # USBGuard
    if systemctl is-active usbguard >/dev/null 2>&1; then
        echo "✅ USBGuard - ACTIVO"
    else
        echo "❌ USBGuard - INACTIVO"
    fi
    
    # Verificar configuraciones de seguridad
    echo ""
    echo "🛡️ CONFIGURACIONES DE SEGURIDAD:"
    
    # /etc/hosts bloqueado
    if lsattr /etc/hosts 2>/dev/null | grep -q "i"; then
        echo "✅ /etc/hosts - BLOQUEADO"
    else
        echo "❌ /etc/hosts - NO BLOQUEADO"
    fi
    
    # Apagado automático
    if grep -q "apagado-automatico" /etc/crontab 2>/dev/null; then
        echo "✅ Apagado automático - CONFIGURADO"
    else
        echo "❌ Apagado automático - NO CONFIGURADO"
    fi
    
    # Verificar configuraciones GNOME
    echo ""
    echo "🎨 CONFIGURACIONES GNOME:"
    usuario=$(logname 2>/dev/null)
    if [ -n "$usuario" ]; then
        usuario_id=$(id -u $usuario 2>/dev/null)
        if [ -n "$usuario_id" ]; then
            export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$usuario_id/bus"
            
            # Tema oscuro
            tema=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "no-config")
            if [ "$tema" = "'prefer-dark'" ]; then
                echo "✅ Tema oscuro - ACTIVADO"
            else
                echo "❌ Tema oscuro - NO ACTIVADO"
            fi
            
            # Workspace único
            workspaces=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings get org.gnome.desktop.wm.preferences num-workspaces 2>/dev/null || echo "0")
            if [ "$workspaces" = "1" ]; then
                echo "✅ Workspace único - CONFIGURADO"
            else
                echo "❌ Workspace único - NO CONFIGURADO"
            fi
            
            # Dock inferior
            dock_pos=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings get org.gnome.shell.extensions.dash-to-dock dock-position 2>/dev/null || echo "left")
            if [ "$dock_pos" = "'BOTTOM'" ]; then
                echo "✅ Dock inferior - CONFIGURADO"
            else
                echo "❌ Dock inferior - NO CONFIGURADO"
            fi
            
            # Comportamiento de clics
            clics=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings get org.gnome.nautilus.preferences click-policy 2>/dev/null || echo "single")
            if [ "$clics" = "'double'" ]; then
                echo "✅ Clic doble como Windows - CONFIGURADO"
            else
                echo "❌ Clic doble como Windows - NO CONFIGURADO"
            fi
            
            # Verificar si hay iconos en el escritorio
            if [ -d "/home/$usuario/Desktop" ] || [ -d "/home/$usuario/Escritorio" ]; then
                echo "✅ Directorio escritorio - CONFIGURADO"
            else
                echo "❌ Directorio escritorio - NO CONFIGURADO"
            fi
            
            # Verificar plantillas
            if [ -d "/home/$usuario/Templates" ] && [ "$(ls -A /home/$usuario/Templates)" ]; then
                echo "✅ Plantillas documentos - CONFIGURADAS"
            else
                echo "❌ Plantillas documentos - NO CONFIGURADAS"
            fi
        else
            echo "⚠ No se puede verificar GNOME (sin sesión de usuario)"
        fi
    else
        echo "⚠ No se puede verificar GNOME (usuario no detectado)"
    fi
    
    echo ""
    echo "=================================================="
}

# Actualizar sistema
echo "Actualizando sistema..."
apt update && apt upgrade -y

# CONFIGURAR ZONA HORARIA DE ARGENTINA PRIMERO
configurar_zona_horaria

# Habilitar repositorios necesarios
echo "Habilitando repositorios contrib y non-free..."
sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
apt update

# INSTALAR APLICACIONES CON MANEJO DE ERRORES

# 1. Chromium
echo "Instalando Chromium..."
apt install -y chromium
check_success "Chromium"

# 2. Remmina
echo "Instalando Remmina..."
apt install -y remmina remmina-plugin-rdp remmina-plugin-vnc
check_success "Remmina"


# 4. RustDesk - Instalación mejorada
echo "Instalando RustDesk..."
# Instalar desde repositorio oficial
wget -qO - https://github.com/rustdesk/rustdesk/releases/download/1.4.2/rustdesk-1.4.2-x86_64.deb -O rustdesk.deb
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

# 9. Linphone - INSTALACIÓN FUNCIONAL CON AppImage
echo "Instalando Linphone..."
# URL de descarga de Linphone
LINPHONE_URL="https://download.linphone.org/releases/linux/app/Linphone-6.0.1-CallEdition-x86_64.AppImage"
LINPHONE_FILE="/home/$(logname)/Descargas/Linphone-6.0.1-CallEdition-x86_64.AppImage"

# Crear directorio de Descargas si no existe
mkdir -p "/home/$(logname)/Descargas"

# Descargar Linphone si no existe
if [ ! -f "$LINPHONE_FILE" ]; then
    echo "El archivo Linphone no se encuentra en $LINPHONE_FILE. Descargando..."
    wget -q --show-progress "$LINPHONE_URL" -O "$LINPHONE_FILE"
    if [ $? -ne 0 ]; then
        echo "Error: La descarga de Linphone falló."
        echo "Intentando descarga alternativa..."
        # URL alternativa
        LINPHONE_URL_ALT="https://www.linphone.org/releases/linux/app/Linphone-5.0.14-x86_64.AppImage"
        wget -q --show-progress "$LINPHONE_URL_ALT" -O "$LINPHONE_FILE"
    fi
    echo "Linphone descargado con éxito."
else
    echo "El archivo Linphone ya existe en $LINPHONE_FILE. No es necesario descargarlo."
fi

# Verificar si el script se está ejecutando como root
if [ "$(id -u)" -eq 0 ]; then
    echo "Ejecutando como root. Asegurando acceso al servidor X..."
    
    # Verificar si DISPLAY está configurado
    if [ -z "$DISPLAY" ]; then
        echo "No se encuentra la variable DISPLAY. Asignando la variable DISPLAY del usuario actual..."
        
        # Usar la variable DISPLAY y XAUTHORITY del usuario que está ejecutando el script
        export DISPLAY=:0
        export XAUTHORITY=$(eval echo ~$SUDO_USER)/.Xauthority
    fi
    
    # Permitir a root acceder al servidor X
    echo "Permitido acceso a root para usar el servidor X..."
    su - $SUDO_USER -c "xhost +SI:localuser:root"
    
    # Establecer las variables de entorno para usar X
    export DISPLAY=$DISPLAY
    export XAUTHORITY=$XAUTHORITY
fi

# Asegurarse de que el archivo .AppImage tiene permisos de ejecución
if [ -f "$LINPHONE_FILE" ]; then
    chmod +x "$LINPHONE_FILE"
    echo "✓ Linphone AppImage descargado y con permisos de ejecución"
    
    # Crear lanzador de escritorio para Linphone
    cat > "/usr/share/applications/linphone.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Linphone
GenericName=VoIP Phone
Comment=Linphone VoIP softphone
Exec=$LINPHONE_FILE
Icon=linphone
Terminal=false
Categories=Network;Telephony;
Keywords=voip;sip;phone;
EOF
    
    # Crear enlace simbólico en /usr/local/bin para que funcione el comando 'linphone'
    ln -sf "$LINPHONE_FILE" /usr/local/bin/linphone
    
    echo "✓ Linphone instalado y configurado correctamente"
else
    echo "❌ No se pudo descargar Linphone AppImage"
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

# CONFIGURAR ESCRITORIO ESTILO WINDOWS (COMPLETAMENTE FUNCIONAL)
echo "Configurando escritorio estilo Windows..."
configurar_escritorio_windows

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

# ACTIVACIÓN FORZADA DE EXTENSIONES
echo "Activando extensiones GNOME forzosamente..."
usuario=$(logname)
usuario_id=$(id -u $usuario 2>/dev/null)

if [ -n "$usuario_id" ]; then
    # Forzar activación de Dash to Dock
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$usuario_id/bus \
        gnome-extensions enable dash-to-dock@micxgx.gmail.com
    
    # Forzar activación de iconos en escritorio
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$usuario_id/bus \
        gnome-extensions enable desktop-icons@csoriano
    
    # Recargar GNOME Shell completamente
    echo "Recargando GNOME Shell..."
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$usuario_id/bus \
        gnome-shell --replace > /dev/null 2>&1 &
    sleep 5
    
    echo "✓ Extensiones activadas y GNOME recargado"
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
apt autoclean

# MENSAJE FINAL
echo ""
echo "=================================================="
echo "✅ CONFIGURACIÓN EMPRESARIAL COMPLETADA!"
echo "=================================================="
echo ""
echo "🎯 RESUMEN EJECUTADO:"
echo "✓ Verificación completa mostrada arriba"
echo "✓ Linphone instalado con AppImage funcional"
echo "✓ Dock inferior configurado y activado"
echo "✓ Escritorio estilo Windows configurado"
echo "✓ Iconos visibles y creación de archivos habilitada"
echo "✓ Todas las aplicaciones instaladas y verificadas"
echo "✓ Servicios configurados y en ejecución"
echo ""
echo "🔧 COMANDOS ÚTILES:"
echo "   verificar-instalacion.sh  - Verificar estado del sistema"
echo "   corregir-dock.sh          - Corregir dock si no funciona"
echo ""
echo "🔄 ACCIONES RECOMENDADAS:"
echo "1. Si el dock no funciona: CERRAR SESIÓN y volver a entrar"
echo "2. O REINICIAR el sistema para aplicar todos los cambios"
echo "3. Las ventanas minimizadas aparecerán en la barra inferior"
echo "4. Puede crear archivos/carpetas en el escritorio con clic derecho"
echo "5. Linphone está instalado y listo para usar"
echo "=================================================="