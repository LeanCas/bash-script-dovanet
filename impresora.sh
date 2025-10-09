#!/bin/bash
# agregar-impresora.sh - Script corregido para usuario normal

# Configuración
IP_IMPRESORA="10.126.67.123"
NOMBRE_IMPRESORA="Impresora-Oficina"
PUERTO="9100"

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Funciones de log
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"; }

# Verificar si tenemos sudo (VERSIÓN CORREGIDA)
check_sudo() {
    log "Verificando permisos..."
    
    # Solo verifica si el usuario TIENE permisos sudo, no si ES root
    if ! sudo -n true 2>/dev/null; then
        log "Se necesitan permisos de administrador..."
        sudo -v
        if [ $? -ne 0 ]; then
            error "No se pudieron obtener permisos sudo"
            exit 1
        fi
    fi
}

# Verificar conectividad con la impresora
check_conectividad() {
    log "Verificando conectividad con la impresora..."
    if ping -c 2 -W 3 "$IP_IMPRESORA" &> /dev/null; then
        log "✅ Impresora responde al ping"
        return 0
    else
        error "❌ No se puede contactar la impresora en $IP_IMPRESORA"
        error "Verifica:"
        error "  - Que la IP sea correcta"
        error "  - Que la impresora esté encendida"
        error "  - Que estés en la misma red"
        return 1
    fi
}

# Verificar si CUPS está instalado y activo
check_cups() {
    log "Verificando servicio CUPS..."
    if ! command -v lpadmin &> /dev/null; then
        warning "CUPS no está instalado, instalando..."
        sudo apt update && sudo apt install -y cups cups-client
    fi
    
    if ! systemctl is-active --quiet cups; then
        warning "Servicio CUPS no está activo, iniciando..."
        sudo systemctl start cups
        sudo systemctl enable cups
    fi
    log "✅ CUPS está instalado y activo"
}

# Verificar si la impresora ya existe
check_impresora_existente() {
    if lpstat -p "$NOMBRE_IMPRESORA" &> /dev/null; then
        warning "La impresora '$NOMBRE_IMPRESORA' ya existe"
        read -p "¿Deseas eliminarla y recrearla? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            log "Eliminando impresora existente..."
            sudo lpadmin -x "$NOMBRE_IMPRESORA"
        else
            log "Manteniendo impresora existente"
            exit 0
        fi
    fi
}

# Agregar la impresora a CUPS
agregar_impresora() {
    log "Agregando impresora a CUPS..."
    
    if sudo lpadmin -p "$NOMBRE_IMPRESORA" -E -v "socket://$IP_IMPRESORA:$PUERTO" -m everywhere; then
        log "✅ Impresora agregada exitosamente"
        return 0
    else
        error "❌ Error al agregar la impresora"
        return 1
    fi
}

# Configurar impresora por defecto
configurar_predeterminada() {
    log "Configurando como impresora por defecto..."
    if sudo lpoptions -d "$NOMBRE_IMPRESORA"; then
        log "✅ Impresora establecida como predeterminada"
    else
        warning "No se pudo establecer como predeterminada, pero la impresora está agregada"
    fi
}

# Mostrar comandos de prueba
mostrar_comandos_prueba() {
    echo
    log "=== COMANDOS PARA PROBAR LA IMPRESORA ==="
    echo
    log "1. Prueba básica de texto:"
    echo "   echo \"Esta es una prueba\" | lp -d $NOMBRE_IMPRESORA"
    echo
    log "2. Prueba con fecha:"
    echo "   echo \"Prueba - \$(date)\" | lp -d $NOMBRE_IMPRESORA"
    echo
    log "3. Imprimir archivo PDF:"
    echo "   lp -d $NOMBRE_IMPRESORA documento.pdf"
    echo
    log "4. Ver estado de la impresora:"
    echo "   lpstat -p $NOMBRE_IMPRESORA"
}

# Mostrar información final
mostrar_resumen() {
    echo
    log "=== CONFIGURACIÓN COMPLETADA ==="
    log "Nombre: $NOMBRE_IMPRESORA"
    log "IP: $IP_IMPRESORA"
    log "URI: socket://$IP_IMPRESORA:$PUERTO"
    log "Driver: everywhere (genérico)"
    echo
    
    log "Estado de la impresora:"
    lpstat -p "$NOMBRE_IMPRESORA"
    
    echo
    mostrar_comandos_prueba
    echo
    log "Para gestionar: http://localhost:631"
}

# Función principal
main() {
    log "Iniciando configuración de impresora..."
    log "IP: $IP_IMPRESORA"
    log "Nombre: $NOMBRE_IMPRESORA"
    
    check_sudo
    check_conectividad
    check_cups
    check_impresora_existente
    agregar_impresora
    configurar_predeterminada
    mostrar_resumen
}

# Ejecutar función principal
main "$@"