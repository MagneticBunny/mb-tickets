#!/bin/bash

# Script para mover tickets entre estados
# Uso: ./move-ticket.sh [ticket] [destino]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Sistema de Tickets MB - Mover Tickets${NC}"
    echo ""
    echo "Uso: $0 [ticket] [destino]"
    echo ""
    echo "Parámetros:"
    echo "  ticket     Nombre del archivo del ticket (con o sin extensión .md)"
    echo "  destino    Estado destino (completed, cancelled, active)"
    echo ""
    echo "Estados disponibles:"
    echo "  - active      Tickets en desarrollo activo"
    echo "  - completed   Tickets terminados exitosamente" 
    echo "  - cancelled   Tickets cancelados"
    echo ""
    echo "Ejemplos:"
    echo "  $0 20250529020058_create_customer_channel_restrictions.md completed"
    echo "  $0 20250529020058_create_customer_channel_restrictions cancelled"
    echo "  $0 20250529020058_create_customer_channel_restrictions active"
    echo ""
    echo "Comandos útiles:"
    echo "  ./find-tickets.sh --activos     # Ver tickets activos"
    echo "  ./find-tickets.sh --estadisticas # Ver estadísticas"
    echo ""
}

# Función para encontrar ticket en cualquier carpeta
find_ticket() {
    local ticket_name="$1"
    
    # Agregar extensión .md si no la tiene
    if [[ ! "$ticket_name" =~ \.md$ ]]; then
        ticket_name="${ticket_name}.md"
    fi
    
    # Buscar en todas las carpetas de estados
    for dir in "tickets/active" "tickets/completed" "tickets/cancelled"; do
        if [ -f "$dir/$ticket_name" ]; then
            echo "$dir/$ticket_name"
            return 0
        fi
    done
    
    return 1
}

# Función para actualizar estado en el ticket
update_ticket_state() {
    local file="$1"
    local new_state="$2"
    local current_date=$(date +"%Y-%m-%d")
    local current_time=$(date +"%H:%M")
    
    case "$new_state" in
        "completed")
            # Marcar como completado
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's/- \[ \] Completado/- [x] Completado/' "$file"
                sed -i '' "s/| YYYY-MM-DD | \[nombre\] | Creación del ticket |/| $current_date | Sistema | Ticket marcado como completado |/" "$file"
            else
                sed -i 's/- \[ \] Completado/- [x] Completado/' "$file"
                sed -i "s/| YYYY-MM-DD | \[nombre\] | Creación del ticket |/| $current_date | Sistema | Ticket marcado como completado |/" "$file"
            fi
            ;;
        "cancelled")
            # Marcar como cancelado
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's/- \[ \] Cancelado/- [x] Cancelado/' "$file"
                sed -i '' "s/| YYYY-MM-DD | \[nombre\] | Creación del ticket |/| $current_date | Sistema | Ticket cancelado |/" "$file"
            else
                sed -i 's/- \[ \] Cancelado/- [x] Cancelado/' "$file"
                sed -i "s/| YYYY-MM-DD | \[nombre\] | Creación del ticket |/| $current_date | Sistema | Ticket cancelado |/" "$file"
            fi
            ;;
        "active")
            # Desmarcar completado y cancelado, marcar en análisis
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's/- \[x\] Completado/- [ ] Completado/' "$file"
                sed -i '' 's/- \[x\] Cancelado/- [ ] Cancelado/' "$file"
                sed -i '' 's/- \[ \] En análisis/- [x] En análisis/' "$file"
                sed -i '' "s/| YYYY-MM-DD | \[nombre\] | Creación del ticket |/| $current_date | Sistema | Ticket reactivado |/" "$file"
            else
                sed -i 's/- \[x\] Completado/- [ ] Completado/' "$file"
                sed -i 's/- \[x\] Cancelado/- [ ] Cancelado/' "$file"
                sed -i 's/- \[ \] En análisis/- [x] En análisis/' "$file"
                sed -i "s/| YYYY-MM-DD | \[nombre\] | Creación del ticket |/| $current_date | Sistema | Ticket reactivado |/" "$file"
            fi
            ;;
    esac
}

# Validar parámetros
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ $# -ne 2 ]; then
    echo -e "${RED}Error: Se requieren exactamente 2 parámetros${NC}"
    echo ""
    show_help
    exit 1
fi

TICKET_NAME="$1"
DESTINATION="$2"

# Validar destino
case "$DESTINATION" in
    "active"|"completed"|"cancelled")
        ;;
    *)
        echo -e "${RED}Error: Estado destino no válido: $DESTINATION${NC}"
        echo "Estados válidos: active, completed, cancelled"
        exit 1
        ;;
esac

# Buscar el ticket
echo -e "${BLUE}Buscando ticket: ${YELLOW}$TICKET_NAME${NC}"
CURRENT_PATH=$(find_ticket "$TICKET_NAME")

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: No se encontró el ticket $TICKET_NAME${NC}"
    echo ""
    echo "Tickets disponibles:"
    ./scripts/find-tickets.sh --activos
    exit 1
fi

# Determinar carpeta actual
CURRENT_DIR=$(dirname "$CURRENT_PATH")
DESTINATION_DIR="tickets/$DESTINATION"

# Verificar si ya está en el destino
if [ "$CURRENT_DIR" = "$DESTINATION_DIR" ]; then
    echo -e "${YELLOW}El ticket ya está en $DESTINATION${NC}"
    exit 0
fi

# Crear directorio destino si no existe
if [ ! -d "$DESTINATION_DIR" ]; then
    echo -e "${YELLOW}Creando directorio $DESTINATION_DIR...${NC}"
    mkdir -p "$DESTINATION_DIR"
fi

# Nombre del archivo
TICKET_FILE=$(basename "$CURRENT_PATH")
DESTINATION_PATH="$DESTINATION_DIR/$TICKET_FILE"

echo -e "${BLUE}Moviendo ticket:${NC}"
echo "  Desde: $CURRENT_PATH"
echo "  Hacia: $DESTINATION_PATH"

# Copiar archivo
cp "$CURRENT_PATH" "$DESTINATION_PATH"

# Actualizar estado en el ticket
update_ticket_state "$DESTINATION_PATH" "$DESTINATION"

# Eliminar archivo original
rm "$CURRENT_PATH"

echo -e "${GREEN}✓ Ticket movido exitosamente a $DESTINATION${NC}"
echo ""

# Mostrar información del ticket
echo -e "${BLUE}Información del ticket:${NC}"
TITLE=$(head -1 "$DESTINATION_PATH" | sed 's/^# //')
echo -e "  📋 Título: ${YELLOW}$TITLE${NC}"
echo "  📁 Ubicación: $DESTINATION_PATH"
echo "  📊 Estado: $DESTINATION"

# Sugerir siguiente acción
case "$DESTINATION" in
    "completed")
        echo ""
        echo -e "${BLUE}💡 Sugerencias:${NC}"
        echo "  - Actualizar el TICKET_INDEX.md"
        echo "  - Considerar archivar si tiene más de 1 mes"
        echo "  - Documentar lecciones aprendidas"
        ;;
    "cancelled")
        echo ""
        echo -e "${BLUE}💡 Sugerencias:${NC}"
        echo "  - Actualizar el TICKET_INDEX.md"
        echo "  - Documentar razón de cancelación en el ticket"
        echo "  - Considerar crear tickets más pequeños si era muy amplio"
        ;;
    "active")
        echo ""
        echo -e "${BLUE}💡 Sugerencias:${NC}"
        echo "  - Asignar desarrollador responsable"
        echo "  - Verificar que todos los requisitos están claros"
        echo "  - Actualizar estimación si es necesario"
        ;;
esac 