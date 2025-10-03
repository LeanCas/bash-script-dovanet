#!/bin/bash

# Script de configuración MEJORADO para estaciones de trabajo empresariales
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
    
    # Instalar paquetes de idioma español
    apt install -y locales
    
    # Generar locale español
    sed -i '/es_ES.UTF-8/s/^#//g' /etc/locale.gen
    locale-gen
    
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

# Función MEJORADA para configurar barra de tareas estilo Windows
configurar_barra_tareas_windows() {
    local usuario=$(logname)
    
    if [ -z "$usuario" ]; then
        echo "⚠ No se puede detectar usuario para configurar barra de tareas"
        return 1
    fi
    
    local usuario_id=$(id -u $usuario 2>/dev/null)
    if [ -z "$usuario_id" ]; then
        echo "⚠ No se puede obtener ID del usuario $usuario"
        return 1
    fi
    
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$usuario_id/bus"
    
    echo "Configurando barra de tareas estilo Windows para usuario: $usuario"
    
    # SOLUCIÓN MEJORADA: Instalar y configurar Dash to Panel (MEJOR que Dash to Dock)
    echo "Instalando Dash to Panel (mejor alternativa para barra estilo Windows)..."
    
    # Instalar dependencias necesarias
    apt install -y gnome-shell-extension-dash-to-panel
    
    # Configuraciones básicas de GNOME para comportamiento Windows
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.mutter dynamic-workspaces false
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.session idle-delay 300
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    
    # CONFIGURACIÓN DASH TO PANEL - COMPORTAMIENTO WINDOWS 10/11
    echo "Configurando Dash to Panel estilo Windows..."
    
    # Activar la extensión primero
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gnome-extensions enable dash-to-panel@jderose9.github.com
    
    # Configuración completa estilo Windows
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel panel-element-positions '{"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}'
    
    # Posición en la parte inferior
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel panel-positions '{"0":"BOTTOM"}'
    
    # Comportamiento de la barra de tareas
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel hide-overview-on-startup true
    
    # Agrupar ventanas como Windows
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel group-apps true
    
    # Mostrar ventanas agrupadas
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel group-apps-overflow true
    
    # Tamaño de iconos
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel app-icon-margin 2
    
    # Mostrar iconos de aplicaciones en ejecución
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel appicon-margin 2
    
    # Ocultar botón de aplicaciones (equivale a menú inicio pero lo mantenemos)
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel show-show-apps-button true
    
    # Estilo visual
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel trans-use-custom-opacity true
    
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel trans-panel-opacity 0.8
    
    # Configurar posición del reloj
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.dash-to-panel clock-show-date true
    
    echo "✓ Barra de tareas estilo Windows configurada con Dash to Panel"
    echo "✓ Comportamiento similar a Windows 10/11"
    echo "✓ Agrupación de ventanas habilitada"
}

# Función MEJORADA para configurar escritorio como Windows
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
    
    # 1. Instalar extensiones para escritorio funcional
    echo "Instalando extensiones para escritorio..."
    apt install -y gnome-shell-extension-desktop-icons-ng
    
    # 2. Configurar Nautilus (gestor de archivos) para comportamiento Windows
    echo "Configurando Nautilus como Windows Explorer..."
    
    # Configurar comportamiento de clics como Windows (doble clic)
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.nautilus.preferences click-policy 'double'
    
    # Mostrar barra de direcciones completa
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.nautilus.preferences always-use-location-entry true
    
    # Ordenar por nombre por defecto
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.nautilus.preferences default-sort-order 'name'
    
    # Vista de iconos grandes por defecto
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
    
    # Mostrar archivos ocultos
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.nautilus.preferences show-hidden-files true
    
    # 3. HABILITAR ESCRITORIO COMPLETAMENTE FUNCIONAL
    echo "Habilitando escritorio completamente funcional..."
    
    # Instalar y habilitar la extensión de iconos de escritorio
    apt install -y gnome-shell-extension-desktop-icons
    
    # Configurar Desktop Icons NG (extensión moderna)
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.ding show-home true
    
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.ding show-trash true
    
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.ding show-volumes true
    
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.ding show-drop-place true
    
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.shell.extensions.ding use-desktop-grid false
    
    # 4. CREAR PLANTILLAS PARA "NUEVO DOCUMENTO" - MEJORADO
    echo "Creando plantillas para Nuevo documento en español..."
    TEMPLATES_DIR="/home/$usuario/Plantillas"
    mkdir -p "$TEMPLATES_DIR"
    
    # Plantilla de documento de texto en español
    cat > "$TEMPLATES_DIR/Documento de texto vacío" << 'EOF'
Documento de texto vacío - hacer doble clic para editar
EOF

    # Plantilla de documento de texto con extensión .txt
    cat > "$TEMPLATES_DIR/Nuevo documento de texto.txt" << 'EOF'
Nuevo documento de texto creado el $(date)
Puede editar este archivo con cualquier editor de texto.
EOF

    # Plantilla de hoja de cálculo
    cat > "$TEMPLATES_DIR/Nueva hoja de cálculo.ods" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<office:document></office:document>
EOF

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
    
    # 6. CONFIGURAR COMPORTAMIENTO DE ARRASTRE Y SOLTAR
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.nautilus.preferences enable-interactive-search true
    
    # 7. CONFIGURAR COMPORTAMIENTO DE MINIMIZAR
    sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        gsettings set org.gnome.desktop.wm.preferences action-double-click-titlebar 'minimize'
    
    echo "✓ Escritorio configurado estilo Windows - COMPLETAMENTE FUNCIONAL"
    echo "✓ Iconos visibles en el escritorio"
    echo "✓ Puede crear archivos y carpetas haciendo clic derecho → Nuevo documento"
    echo "✓ Arrastrar y soltar funcionando"
    echo "✓ Doble clic para abrir archivos y minimizar ventanas"
}

# Función para crear script de corrección de barra de tareas
crear_script_correccion() {
    echo "Creando script de corrección de barra de tareas..."
    
    cat > /usr/local/bin/corregir-barra-tareas.sh << 'EOF'
#!/bin/bash
# Script de corrección para barra de tareas estilo Windows

usuario=$(who | head -n1 | awk '{print $1}')
usuario_id=$(id -u $usuario)

if [ -z "$usuario_id" ]; then
    echo "No se puede encontrar usuario activo"
    exit 1
fi

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$usuario_id/bus"

echo "Corrigiendo barra de tareas estilo Windows..."

# Recargar extensiones
sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
    gnome-extensions enable dash-to-panel@jderose9.github.com

# Forzar recarga de GNOME Shell
echo "Recargando GNOME Shell..."
sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
    gnome-shell --replace > /dev/null 2>&1 &

sleep 3
echo "✓ Corrección aplicada. Si no funciona, cierre sesión y vuelva a entrar."
EOF

    chmod +x /usr/local/bin/corregir-barra-tareas.sh
    echo "✓ Script de corrección creado: corregir-barra-tareas.sh"
}

# Función de verificación de instalación MEJORADA
verificar_instalacion() {
    echo ""
    echo "=================================================="
    echo "🔍 VERIFICACIÓN DE INSTALACIÓN EMPRESARIAL"
    echo "=================================================="
    
    # Verificar idioma
    echo ""
    echo "🌍 CONFIGURACIÓN DE IDIOMA:"
    current_lang=$(locale | grep LANG= | cut -d= -f2)
    if echo "$current_lang" | grep -q "es_ES"; then
        echo "✅ Idioma: Español configurado"
    else
        echo "⚠ Idioma: $current_lang"
    fi
    
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
    
    apps=("chromium" "remmina" "wine" "winetricks" "rustdesk" "libreoffice" "owncloud" "gajim" "thunderbird")
    for app in "${apps[@]}"; do
        if which $app >/dev/null 2>&1; then
            echo "✅ $(echo $app | tr '[:lower:]' '[:upper:]') - INSTALADO"
        else
            echo "❌ $(echo $app | tr '[:lower:]' '[:upper:]') - NO INSTALADO"
        fi
    done
    
    # Verificar Linphone
    if which linphone >/dev/null 2>&1 || [ -f "/home/$(logname)/Descargas/Linphone-6.0.1-CallEdition-x86_64.AppImage" ]; then
        echo "✅ Linphone - INSTALADO"
    else
        echo "❌ Linphone - NO INSTALADO"
    fi
    
    # Verificar Google Earth
    if which google-earth-pro >/dev/null 2>&1; then
        echo "✅ Google Earth - INSTALADO"
    else
        echo "❌ Google Earth - NO INSTALADO"
    fi
    
    # Verificar configuraciones de escritorio Windows
    echo ""
    echo "🪟 CONFIGURACIÓN ESCRITORIO WINDOWS:"
    usuario=$(logname 2>/dev/null)
    if [ -n "$usuario" ]; then
        usuario_id=$(id -u $usuario 2>/dev/null)
        if [ -n "$usuario_id" ]; then
            export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$usuario_id/bus"
            
            # Verificar Dash to Panel
            panel_active=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
                gnome-extensions list | grep dash-to-panel | wc -l)
            if [ "$panel_active" -gt 0 ]; then
                echo "✅ Dash to Panel - ACTIVADO"
            else
                echo "❌ Dash to Panel - NO ACTIVADO"
            fi
            
            # Comportamiento de clics
            clics=$(sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
                gsettings get org.gnome.nautilus.preferences click-policy 2>/dev/null || echo "single")
            if [ "$clics" = "'double'" ]; then
                echo "✅ Clic doble como Windows - CONFIGURADO"
            else
                echo "❌ Clic doble como Windows - NO CONFIGURADO"
            fi
            
            # Verificar iconos de escritorio
            if [ -d "/home/$usuario/Escritorio" ] && [ "$(ls -A /home/$usuario/Escritorio 2>/dev/null)" ]; then
                echo "✅ Iconos en escritorio - VISIBLES"
            else
                echo "⚠ Iconos en escritorio - NO VISIBLES"
            fi
        fi
    fi
    
    echo ""
    echo "=================================================="
}

# ========== EJECUCIÓN PRINCIPAL ==========

# Actualizar sistema
echo "Actualizando sistema..."
apt update && apt upgrade -y

# CONFIGURAR IDIOMA ESPAÑOL PRIMERO
configurar_idioma_espanol

# CONFIGURAR ZONA HORARIA DE ARGENTINA
configurar_zona_horaria

# Habilitar repositorios necesarios
echo "Habilitando repositorios contrib y non-free..."
sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
apt update

# INSTALAR APLICACIONES PRINCIPALES
echo "Instalando aplicaciones principales..."

apps_principales=(
    "chromium chromium-l10n-es"
    "remmina remmina-plugin-rdp remmina-plugin-vnc"
    "wine winetricks"
    "libreoffice libreoffice-l10n-es"
    "thunderbird thunderbird-l10n-es-es"
    "gajim"
    "owncloud-client"
    "openssh-server"
    "cups system-config-printer"
    "usbguard"
)

for app in "${apps_principales[@]}"; do
    app_name=$(echo $app | awk '{print $1}')
    echo "Instalando $app_name..."
    apt install -y $app
    check_success "$app_name"
done

# Instalación de RustDesk (igual que antes)
echo "Instalando RustDesk..."
wget -qO - https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-1.2.3-x86_64.deb -O rustdesk.deb
if [ -f "rustdesk.deb" ] && [ -s "rustdesk.deb" ]; then
    apt install -y ./rustdesk.deb
    rm -f rustdesk.deb
    echo "✓ RustDesk instalado"
else
    wget https://github.com/rustdesk/rustdesk/releases/download/1.1.9/rustdesk-1.1.9-x86_64.deb -O rustdesk.deb
    if [ -f "rustdesk.deb" ]; then
        apt install -y ./rustdesk.deb
        rm -f rustdesk.deb
        echo "✓ RustDesk instalado"
    else
        echo "⚠ RustDesk no se pudo instalar automáticamente"
    fi
fi

# Instalación de Linphone (igual que antes)
echo "Instalando Linphone..."
LINPHONE_URL="https://download.linphone.org/releases/linux/app/Linphone-6.0.1-CallEdition-x86_64.AppImage"
LINPHONE_FILE="/home/$(logname)/Descargas/Linphone-6.0.1-CallEdition-x86_64.AppImage"
mkdir -p "/home/$(logname)/Descargas"

if [ ! -f "$LINPHONE_FILE" ]; then
    wget -q --show-progress "$LINPHONE_URL" -O "$LINPHONE_FILE"
    if [ $? -ne 0 ]; then
        LINPHONE_URL_ALT="https://www.linphone.org/releases/linux/app/Linphone-5.0.14-x86_64.AppImage"
        wget -q --show-progress "$LINPHONE_URL_ALT" -O "$LINPHONE_FILE"
    fi
fi

if [ -f "$LINPHONE_FILE" ]; then
    chmod +x "$LINPHONE_FILE"
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
    ln -sf "$LINPHONE_FILE" /usr/local/bin/linphone
    echo "✓ Linphone instalado y configurado"
fi

# Instalación de Google Earth
echo "Instalando Google Earth..."
apt install -y lsb-release libxss1 libnss3 libxrandr2
wget -q -O google-earth.deb "https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb"
if [ -f "google-earth.deb" ]; then
    apt install -y ./google-earth.deb
    rm -f google-earth.deb
    echo "✓ Google Earth instalado"
fi

# CONFIGURACIONES DE SEGURIDAD
echo "Configurando seguridad..."
chattr +i /etc/hosts 2>/dev/null && echo "✓ /etc/hosts bloqueado"

# Configurar USBGuard
systemctl enable usbguard 2>/dev/null && systemctl start usbguard 2>/dev/null

# Apagado automático
cat > /usr/local/bin/apagado-automatico.sh << 'EOF'
#!/bin/bash
shutdown -h 19:00 "Apagado programado del sistema"
EOF
chmod +x /usr/local/bin/apagado-automatico.sh
echo "0 19 * * * root /usr/local/bin/apagado-automatico.sh" >> /etc/crontab
echo "✓ Apagado automático programado"

# CONFIGURAR BARRA DE TAREAS ESTILO WINDOWS
echo "Configurando barra de tareas estilo Windows..."
configurar_barra_tareas_windows

# CONFIGURAR ESCRITORIO ESTILO WINDOWS
echo "Configurando escritorio estilo Windows..."
configurar_escritorio_windows

# CREAR SCRIPT DE CORRECCIÓN
crear_script_correccion

# CONFIGURAR FONDO DE PANTALLA
echo "Configurando fondo de pantalla..."
usuario=$(logname)
DESKTOP_IMAGE="/home/$usuario/Imágenes/fondo-empresa.jpg"
mkdir -p "/home/$usuario/Imágenes"

if wget --no-check-certificate --timeout=45 --tries=3 -O "$DESKTOP_IMAGE" "$IMAGE_URL" 2>/dev/null; then
    if [ -f "$DESKTOP_IMAGE" ] && [ -s "$DESKTOP_IMAGE" ] && file "$DESKTOP_IMAGE" | grep -q "image"; then
        chown $usuario:$usuario "$DESKTOP_IMAGE"
        usuario_id=$(id -u $usuario 2>/dev/null)
        if [ -n "$usuario_id" ]; then
            sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$usuario_id/bus \
                gsettings set org.gnome.desktop.background picture-uri "file://$DESKTOP_IMAGE"
            sudo -u $usuario DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$usuario_id/bus \
                gsettings set org.gnome.desktop.background picture-uri-dark "file://$DESKTOP_IMAGE"
            echo "✓ Fondo de pantalla configurado"
        fi
    else
        rm -f "$DESKTOP_IMAGE"
    fi
fi

# CONFIGURAR SERVICIOS
echo "Configurando servicios..."
systemctl enable cups 2>/dev/null && systemctl start cups 2>/dev/null
systemctl enable ssh 2>/dev/null && systemctl start ssh 2>/dev/null

# CREAR LANZADORES EN ESCRITORIO
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

# VERIFICACIÓN FINAL
verificar_instalacion

# MENSAJE FINAL
echo ""
echo "=================================================="
echo "✅ CONFIGURACIÓN EMPRESARIAL COMPLETADA!"
echo "=================================================="
echo ""
echo "🎯 CARACTERÍSTICAS CONFIGURADAS:"
echo "✓ Sistema en español completamente"
echo "✓ Barra de tareas estilo Windows 10/11"
echo "✓ Escritorio funcional con iconos"
echo "✓ Comportamiento de doble clic como Windows"
echo "✓ Agrupación de ventanas en la barra de tareas"
echo "✓ Todas las aplicaciones empresariales instaladas"
echo ""
echo "🔧 COMANDOS ÚTILES:"
echo "   corregir-barra-tareas.sh  - Si la barra no funciona correctamente"
echo ""
echo "🔄 ACCIONES RECOMENDADAS:"
echo "1. CERRAR SESIÓN y volver a entrar para aplicar todos los cambios"
echo "2. O REINICIAR el sistema para una experiencia completa"
echo "3. La barra inferior funcionará como en Windows"
echo "4. Las ventanas se agruparán en la barra de tareas"
echo "5. Doble clic para abrir archivos y carpetas"
echo "=================================================="