#!/bin/bash

# Script para crear nuevos tickets
# Uso: ./create-ticket.sh nombre_del_ticket [servicio]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Sistema de Tickets MB - Crear Nuevo Ticket${NC}"
    echo ""
    echo "Uso: $0 nombre_del_ticket [servicio]"
    echo ""
    echo "Parámetros:"
    echo "  nombre_del_ticket    Nombre descriptivo del ticket (usar snake_case)"
    echo "  servicio            Servicio afectado (opcional)"
    echo ""
    echo "Servicios disponibles:"
    echo "  - mb-business"
    echo "  - mb-commerce-channels"
    echo "  - mb-frontend"
    echo "  - mb-cloud-automation"
    echo "  - mb-db"
    echo "  - mb-agents"
    echo "  - test-service"
    echo ""
    echo "Ejemplos:"
    echo "  $0 create_user_authentication_middleware mb-business"
    echo "  $0 implement_payment_gateway_integration mb-commerce-channels"
    echo "  $0 add_customer_notification_system"
    echo ""
}

# Validar parámetros
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

TICKET_NAME="$1"
SERVICE="$2"

# Validar nombre del ticket
if [[ ! "$TICKET_NAME" =~ ^[a-z0-9_]+$ ]]; then
    echo -e "${RED}Error: El nombre del ticket debe usar snake_case (solo letras minúsculas, números y guiones bajos)${NC}"
    echo "Ejemplo: create_user_authentication_middleware"
    exit 1
fi

# Generar timestamp
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
TICKET_FILE="tickets/active/${TIMESTAMP}_${TICKET_NAME}.md"

# Verificar que existe el directorio tickets/active
if [ ! -d "tickets/active" ]; then
    echo -e "${YELLOW}Creando directorio tickets/active/...${NC}"
    mkdir -p tickets/active
fi

# Verificar que existe la plantilla
if [ ! -f "templates/ticket-template.md" ]; then
    echo -e "${RED}Error: No se encontró la plantilla en templates/ticket-template.md${NC}"
    exit 1
fi

# Crear el ticket desde la plantilla
cp templates/ticket-template.md "$TICKET_FILE"

# Actualizar YAML frontmatter
CURRENT_DATE=$(date +"%Y-%m-%d")
TARGET_DATE=$(date -d "+1 week" +"%Y-%m-%d" 2>/dev/null || date -v+1w +"%Y-%m-%d" 2>/dev/null || echo "$CURRENT_DATE")

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/id: \"\"/id: \"$TIMESTAMP\"/" "$TICKET_FILE"
    sed -i '' "s/created: \"\[YYYY-MM-DD\]\"/created: \"$CURRENT_DATE\"/" "$TICKET_FILE"
    sed -i '' "s/target_date: \"\[YYYY-MM-DD\]\"/target_date: \"$TARGET_DATE\"/" "$TICKET_FILE"
    sed -i '' "s/\[YYYY-MM-DD\]/$CURRENT_DATE/g" "$TICKET_FILE"
    
    # Si se especificó un servicio, actualizar
    if [ -n "$SERVICE" ]; then
        sed -i '' "s/service: \"\[nombre del servicio\]\"/service: \"$SERVICE\"/" "$TICKET_FILE"
        sed -i '' "s/\[nombre del servicio\]/$SERVICE/g" "$TICKET_FILE"
    fi
else
    # Linux
    sed -i "s/id: \"\"/id: \"$TIMESTAMP\"/" "$TICKET_FILE"
    sed -i "s/created: \"\[YYYY-MM-DD\]\"/created: \"$CURRENT_DATE\"/" "$TICKET_FILE"
    sed -i "s/target_date: \"\[YYYY-MM-DD\]\"/target_date: \"$TARGET_DATE\"/" "$TICKET_FILE"
    sed -i "s/\[YYYY-MM-DD\]/$CURRENT_DATE/g" "$TICKET_FILE"
    
    # Si se especificó un servicio, actualizar
    if [ -n "$SERVICE" ]; then
        sed -i "s/service: \"\[nombre del servicio\]\"/service: \"$SERVICE\"/" "$TICKET_FILE"
        sed -i "s/\[nombre del servicio\]/$SERVICE/g" "$TICKET_FILE"
    fi
fi

# Mostrar resultado
echo -e "${GREEN}✓ Ticket creado exitosamente:${NC} $TICKET_FILE"
echo ""
echo -e "${BLUE}Información del ticket:${NC}"
echo "  - ID: $TIMESTAMP"
echo "  - Nombre: $TICKET_NAME"
if [ -n "$SERVICE" ]; then
    echo "  - Servicio: $SERVICE"
fi
echo "  - Fecha creación: $CURRENT_DATE"
echo "  - Fecha objetivo: $TARGET_DATE"
echo "  - Archivo: $TICKET_FILE"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Editar el archivo para completar todos los campos"
echo "2. Actualizar el YAML frontmatter con tags, dependencias, etc."
echo "3. Revisar y validar los criterios de aceptación"
echo "4. Asignar responsable y prioridad"
echo ""
echo -e "${BLUE}Para editar el ticket:${NC}"
echo "  code $TICKET_FILE"
echo "  # o"
echo "  vim $TICKET_FILE" 