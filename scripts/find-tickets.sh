#!/bin/bash

# Script para buscar tickets
# Uso: ./find-tickets.sh [opciones]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables por defecto
SEARCH_DIR="tickets"
ESTADO=""
SERVICIO=""
PRIORIDAD=""
ASSIGNEE=""
TAGS=""
TEXT_SEARCH=""
SHOW_STATS=false
JSON_OUTPUT=false

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Sistema de Tickets MB - Búsqueda de Tickets${NC}"
    echo ""
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones de filtrado:"
    echo "  -s, --estado ESTADO         Filtrar por estado (active, completed, cancelled)"
    echo "  -v, --servicio SERVICIO     Filtrar por servicio"
    echo "  -p, --prioridad PRIORIDAD   Filtrar por prioridad (Alta, Media, Baja)"
    echo "  -a, --assignee PERSONA      Filtrar por persona asignada"
    echo "  -t, --tags TAG              Filtrar por tags (separados por coma)"
    echo "  -q, --query TEXTO           Búsqueda de texto en contenido"
    echo ""
    echo "Opciones de salida:"
    echo "  --stats                     Mostrar estadísticas detalladas"
    echo "  --json                      Salida en formato JSON"
    echo "  -h, --help                  Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 --estado active --prioridad Alta"
    echo "  $0 --servicio mb-business --assignee 'Juan Pérez'"
    echo "  $0 --tags 'cache,validacion' --stats"
    echo "  $0 --query 'restricciones' --estado active"
    echo ""
}

# Función para extraer valor YAML
extract_yaml_value() {
    local file="$1"
    local key="$2"
    local value=$(grep "^$key:" "$file" | sed 's/^[^:]*: *//' | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")
    echo "$value"
}

# Función para extraer array YAML
extract_yaml_array() {
    local file="$1"
    local key="$2"
    local line=$(grep "^$key:" "$file" | sed 's/^[^:]*: *//')
    # Extraer elementos del array [item1, item2, item3]
    echo "$line" | sed 's/\[//g' | sed 's/\]//g' | sed 's/"//g' | sed "s/'//g"
}

# Función para verificar si un archivo coincide con los filtros
matches_filters() {
    local file="$1"
    
    # Verificar que el archivo existe y tiene YAML frontmatter
    if [ ! -f "$file" ] || ! head -1 "$file" | grep -q "^---$"; then
        return 1
    fi
    
    # Filtro por estado
    if [ -n "$ESTADO" ]; then
        local file_estado=""
        case "$file" in
            */active/*) file_estado="active" ;;
            */completed/*) file_estado="completed" ;;
            */cancelled/*) file_estado="cancelled" ;;
        esac
        if [ "$file_estado" != "$ESTADO" ]; then
            return 1
        fi
    fi
    
    # Filtro por servicio
    if [ -n "$SERVICIO" ]; then
        local file_servicio=$(extract_yaml_value "$file" "service")
        if [ "$file_servicio" != "$SERVICIO" ]; then
            return 1
        fi
    fi
    
    # Filtro por prioridad
    if [ -n "$PRIORIDAD" ]; then
        local file_prioridad=$(extract_yaml_value "$file" "priority")
        if [ "$file_prioridad" != "$PRIORIDAD" ]; then
            return 1
        fi
    fi
    
    # Filtro por assignee
    if [ -n "$ASSIGNEE" ]; then
        local file_assignee=$(extract_yaml_value "$file" "assignee")
        if [[ "$file_assignee" != *"$ASSIGNEE"* ]]; then
            return 1
        fi
    fi
    
    # Filtro por tags
    if [ -n "$TAGS" ]; then
        local file_tags=$(extract_yaml_array "$file" "tags")
        local found_tag=false
        IFS=',' read -ra TAG_ARRAY <<< "$TAGS"
        for tag in "${TAG_ARRAY[@]}"; do
            tag=$(echo "$tag" | xargs) # trim whitespace
            if [[ "$file_tags" == *"$tag"* ]]; then
                found_tag=true
                break
            fi
        done
        if [ "$found_tag" = false ]; then
            return 1
        fi
    fi
    
    # Filtro por texto
    if [ -n "$TEXT_SEARCH" ]; then
        if ! grep -i -q "$TEXT_SEARCH" "$file"; then
            return 1
        fi
    fi
    
    return 0
}

# Función para mostrar información de un ticket
show_ticket_info() {
    local file="$1"
    local filename=$(basename "$file")
    local estado=""
    
    # Determinar estado por directorio
    case "$file" in
        */active/*) estado="${GREEN}ACTIVO${NC}" ;;
        */completed/*) estado="${BLUE}COMPLETADO${NC}" ;;
        */cancelled/*) estado="${RED}CANCELADO${NC}" ;;
    esac
    
    if [ "$JSON_OUTPUT" = true ]; then
        # Salida JSON
        local id=$(extract_yaml_value "$file" "id")
        local service=$(extract_yaml_value "$file" "service")
        local priority=$(extract_yaml_value "$file" "priority")
        local assignee=$(extract_yaml_value "$file" "assignee")
        local created=$(extract_yaml_value "$file" "created")
        local title=$(grep "^# " "$file" | head -1 | sed 's/^# //')
        
        echo "{"
        echo "  \"file\": \"$file\","
        echo "  \"id\": \"$id\","
        echo "  \"title\": \"$title\","
        echo "  \"service\": \"$service\","
        echo "  \"priority\": \"$priority\","
        echo "  \"assignee\": \"$assignee\","
        echo "  \"created\": \"$created\","
        echo "  \"estado\": \"$(echo "$estado" | sed 's/\x1b\[[0-9;]*m//g')\""
        echo "},"
    else
        # Salida normal
        echo -e "${CYAN}📄 $filename${NC}"
        echo -e "   Estado: $estado"
        
        # Extraer información del YAML frontmatter
        local service=$(extract_yaml_value "$file" "service")
        local priority=$(extract_yaml_value "$file" "priority")
        local assignee=$(extract_yaml_value "$file" "assignee")
        local created=$(extract_yaml_value "$file" "created")
        local estimation=$(extract_yaml_value "$file" "estimation")
        
        if [ -n "$service" ] && [ "$service" != "[nombre del servicio]" ]; then
            echo -e "   Servicio: ${YELLOW}$service${NC}"
        fi
        if [ -n "$priority" ] && [ "$priority" != "[Alta/Media/Baja]" ]; then
            case "$priority" in
                "Alta") echo -e "   Prioridad: ${RED}$priority${NC}" ;;
                "Media") echo -e "   Prioridad: ${YELLOW}$priority${NC}" ;;
                "Baja") echo -e "   Prioridad: ${GREEN}$priority${NC}" ;;
                *) echo -e "   Prioridad: $priority" ;;
            esac
        fi
        if [ -n "$assignee" ] && [ "$assignee" != "[desarrollador responsable]" ]; then
            echo -e "   Asignado: ${PURPLE}$assignee${NC}"
        fi
        if [ -n "$created" ] && [ "$created" != "[YYYY-MM-DD]" ]; then
            echo -e "   Creado: $created"
        fi
        if [ -n "$estimation" ] && [ "$estimation" != "[XS/S/M/L/XL]" ]; then
            echo -e "   Estimación: $estimation"
        fi
        
        # Mostrar título
        local title=$(grep "^# " "$file" | head -1 | sed 's/^# //')
        if [ -n "$title" ] && [ "$title" != "[Nombre del Feature]" ]; then
            echo -e "   Título: ${CYAN}$title${NC}"
        fi
        
        echo -e "   Archivo: $file"
        echo ""
    fi
}

# Función para contar por servicio (alternativa a array asociativo)
count_by_service() {
    local files=("$@")
    local services=()
    
    # Obtener lista de servicios únicos
    for file in "${files[@]}"; do
        local service=$(extract_yaml_value "$file" "service")
        if [ -n "$service" ] && [ "$service" != "[nombre del servicio]" ]; then
            # Verificar si el servicio ya está en la lista
            local found=false
            for existing in "${services[@]}"; do
                if [ "$existing" = "$service" ]; then
                    found=true
                    break
                fi
            done
            if [ "$found" = false ]; then
                services+=("$service")
            fi
        fi
    done
    
    # Contar por cada servicio
    echo -e "${YELLOW}Por Servicio:${NC}"
    for service in "${services[@]}"; do
        local count=0
        for file in "${files[@]}"; do
            local file_service=$(extract_yaml_value "$file" "service")
            if [ "$file_service" = "$service" ]; then
                count=$((count + 1))
            fi
        done
        echo "  🔧 $service: $count"
    done
}

# Función para mostrar estadísticas
show_statistics() {
    local found_files=("$@")
    
    echo -e "${BLUE}📊 Estadísticas de Búsqueda${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Total tickets encontrados: ${GREEN}${#found_files[@]}${NC}"
    echo ""
    
    # Estadísticas por estado
    local active_count=0
    local completed_count=0
    local cancelled_count=0
    
    # Estadísticas por prioridad
    local high_count=0
    local medium_count=0
    local low_count=0
    
    for file in "${found_files[@]}"; do
        # Contar por estado
        case "$file" in
            */active/*) active_count=$((active_count + 1)) ;;
            */completed/*) completed_count=$((completed_count + 1)) ;;
            */cancelled/*) cancelled_count=$((cancelled_count + 1)) ;;
        esac
        
        # Contar por prioridad
        local priority=$(extract_yaml_value "$file" "priority")
        case "$priority" in
            "Alta") high_count=$((high_count + 1)) ;;
            "Media") medium_count=$((medium_count + 1)) ;;
            "Baja") low_count=$((low_count + 1)) ;;
        esac
    done
    
    # Mostrar estadísticas por estado
    echo -e "${YELLOW}Por Estado:${NC}"
    echo "  🟢 Activos: $active_count"
    echo "  🔵 Completados: $completed_count"
    echo "  🔴 Cancelados: $cancelled_count"
    echo ""
    
    # Mostrar estadísticas por prioridad
    echo -e "${YELLOW}Por Prioridad:${NC}"
    echo "  🔴 Alta: $high_count"
    echo "  🟡 Media: $medium_count"
    echo "  🟢 Baja: $low_count"
    echo ""
    
    # Mostrar estadísticas por servicio
    count_by_service "${found_files[@]}"
    echo ""
}

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--estado)
            ESTADO="$2"
            shift 2
            ;;
        -v|--servicio)
            SERVICIO="$2"
            shift 2
            ;;
        -p|--prioridad)
            PRIORIDAD="$2"
            shift 2
            ;;
        -a|--assignee)
            ASSIGNEE="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -q|--query)
            TEXT_SEARCH="$2"
            shift 2
            ;;
        --stats)
            SHOW_STATS=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Opción desconocida '$1'${NC}"
            echo "Usa '$0 --help' para ver las opciones disponibles."
            exit 1
            ;;
    esac
done

# Verificar que existe el directorio de tickets
if [ ! -d "$SEARCH_DIR" ]; then
    echo -e "${RED}Error: No se encontró el directorio '$SEARCH_DIR'${NC}"
    exit 1
fi

# Buscar archivos que coincidan con los filtros
echo -e "${BLUE}🔍 Buscando tickets...${NC}"
echo ""

found_files=()
for dir in "$SEARCH_DIR/active" "$SEARCH_DIR/completed" "$SEARCH_DIR/cancelled"; do
    if [ -d "$dir" ]; then
        for file in "$dir"/*.md; do
            if [ -f "$file" ] && matches_filters "$file"; then
                found_files+=("$file")
            fi
        done
    fi
done

# Mostrar resultados
if [ ${#found_files[@]} -eq 0 ]; then
    echo -e "${YELLOW}No se encontraron tickets que coincidan con los criterios especificados.${NC}"
    exit 0
fi

# Salida JSON
if [ "$JSON_OUTPUT" = true ]; then
    echo "["
    for i in "${!found_files[@]}"; do
        show_ticket_info "${found_files[$i]}"
    done
    # Remover la última coma (usando un enfoque más simple)
    echo "]" | sed 's/,]/]/'
else
    # Salida normal
    for file in "${found_files[@]}"; do
        show_ticket_info "$file"
    done
    
    # Mostrar estadísticas si se solicitó
    if [ "$SHOW_STATS" = true ]; then
        show_statistics "${found_files[@]}"
    fi
fi 