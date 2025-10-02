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

# Función para configurar escritorio como Windows (iconos, crear archivos, etc.)
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
    
    # 1. Instalar extensiones para iconos en el escritorio
    echo "Instalando extensiones para escritorio..."
    apt install -y gnome-shell-extension-desktop-icons-ng
    
    # 2. Habilitar iconos en el escritorio
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.background show-desktop-icons true
    
    # 3. Configurar Nautilus (gestor de archivos) para comportamiento como Windows
    echo "Configurando Nautilus como Windows Explorer..."
    
    # Mostrar iconos de equipo y carpetas en el escritorio
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-home true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-trash true
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-volumes true
    
    # Configurar comportamiento de clics como Windows (doble clic)
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences click-policy 'double'
    
    # Mostrar barra de direcciones completa
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences always-use-location-entry true
    
    # Ordenar por nombre por defecto
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences default-sort-order 'name'
    
    # Vista de iconos grandes por defecto
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
    
    # 4. Crear plantillas para "Nuevo documento" en el menú contextual
    echo "Creando plantillas para Nuevo documento..."
    TEMPLATES_DIR="/home/$usuario/Plantillas"
    mkdir -p "$TEMPLATES_DIR"
    
    # Plantilla de documento de texto
    cat > "$TEMPLATES_DIR/Documento de texto.txt" << 'EOF'
Documento creado el $(date)
EOF

    # Plantilla de hoja de cálculo
    cat > "$TEMPLATES_DIR/Hoja de cálculo.ods" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<office:document xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0">
<!-- Hoja de cálculo vacía -->
</office:document>
EOF

    # Asegurar permisos
    chown -R $usuario:$usuario "$TEMPLATES_DIR"
    
    # 5. Configurar menú contextual del escritorio
    echo "Configurando menú contextual del escritorio..."
    
    # Crear script para agregar "Nuevo" al menú contextual
    cat > "/usr/local/bin/nuevo-documento.sh" << 'EOF'
#!/bin/bash
# Script para crear nuevos documentos desde el escritorio
zenity --forms --title="Crear nuevo documento" \
       --text="Seleccione el tipo de documento:" \
       --add-combo="Tipo" --combo-values="Documento de texto|Hoja de cálculo|Carpeta" \
       --add-entry="Nombre:"
EOF
    chmod +x /usr/local/bin/nuevo-documento.sh
    
    # 6. Configurar atajos de teclado como Windows
    echo "Configurando atajos de teclado estilo Windows..."
    
    # Win + E para abrir el explorador de archivos
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
    
    # Win + D para mostrar el escritorio
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
    
    # 7. Configurar papelera visible en el escritorio
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.shell.extensions.ding show-trash true
    
    # 8. Habilitar la creación de archivos y carpetas en el escritorio
    echo "Habilitando creación de archivos en el escritorio..."
    
    # Crear directorio Escritorio si no existe
    DESKTOP_DIR="/home/$usuario/Escritorio"
    mkdir -p "$DESKTOP_DIR"
    chown $usuario:$usuario "$DESKTOP_DIR"
    
    # Configurar permisos para que el usuario pueda crear archivos
    chmod 755 "$DESKTOP_DIR"
    
    echo "✓ Escritorio configurado estilo Windows"
    echo "✓ Iconos visibles en el escritorio"
    echo "✓ Puede crear archivos y carpetas haciendo clic derecho"
    echo "✓ Plantillas disponibles en 'Nuevo documento'"
}

# Función de verificación de instalación
verificar_instalacion() {
    echo ""
    echo "=================================================="
    echo "🔍 VERIFICACIÓN DE INSTALACIÓN EMPRESARIAL"
    echo "=================================================="
    
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
    if which linphone >/dev/null 2>&1 || flatpak list | grep -q linphone || dpkg -l | grep -q linphone; then
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
            
            # Iconos en escritorio
            iconos=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings get org.gnome.desktop.background show-desktop-icons 2>/dev/null || echo "false")
            if [ "$iconos" = "true" ]; then
                echo "✅ Iconos en escritorio - ACTIVADOS"
            else
                echo "❌ Iconos en escritorio - DESACTIVADOS"
            fi
            
            # Comportamiento de clics
            clics=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings get org.gnome.nautilus.preferences click-policy 2>/dev/null || echo "single")
            if [ "$clics" = "'double'" ]; then
                echo "✅ Clic doble como Windows - CONFIGURADO"
            else
                echo "❌ Clic doble como Windows - NO CONFIGURADO"
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

# 9. Linphone - CON REPOSITORIOS NO OFICIALES
echo "Instalando Linphone desde repositorios no oficiales..."
echo "Agregando repositorios para Linphone..."

# Método 1: Repositorio de Debian testing
echo "Agregando repositorio testing..."
echo "deb http://deb.debian.org/debian testing main" >> /etc/apt/sources.list.d/linphone.list

# Método 2: Repositorio de Ubuntu (compatible con Debian)
echo "Agregando repositorio Ubuntu compatible..."
echo "deb http://archive.ubuntu.com/ubuntu jammy universe" >> /etc/apt/sources.list.d/linphone.list

# Método 3: Repositorio de Linphone oficial
echo "Agregando repositorio oficial de Linphone..."
wget -qO - https://linphone.org/releases/linphone-key.asc | apt-key add -
echo "deb https://linphone.org/releases/ubuntu/ jammy main" >> /etc/apt/sources.list.d/linphone.list

# Actualizar con nuevos repositorios
apt update

# Instalar Linphone con prioridad de repositorios
echo "Instalando Linphone desde múltiples fuentes..."
if apt install -y linphone 2>/dev/null; then
    echo "✓ Linphone instalado desde repositorios"
else
    # Si falla, intentar con repositorio específico
    echo "Intentando instalación forzada..."
    apt install -y -t testing linphone 2>/dev/null || \
    apt install -y --allow-unauthenticated linphone 2>/dev/null || \
    echo "⚠ Linphone no disponible en repositorios configurados"
    
    # Último intento: compilar desde fuente
    echo "Intentando compilación desde fuente..."
    apt install -y build-essential cmake git pkg-config \
        libbcg729-dev libbctoolbox-dev libbelcard-dev libbelr-dev \
        liblinphone-dev linphone-desktop
    if which linphone >/dev/null 2>&1; then
        echo "✓ Linphone compilado e instalado"
    else
        echo "❌ Linphone no se pudo instalar"
        echo "   Instalar manualmente desde: https://linphone.org/releases"
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

# CONFIGURAR ESCRITORIO ESTILO WINDOWS
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
    
    echo "✓ Extensiones activadas y GNOME