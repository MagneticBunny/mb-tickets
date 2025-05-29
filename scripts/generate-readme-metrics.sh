#!/bin/bash

# Script para generar métricas para el README
# Uso: ./generate-readme-metrics.sh

set -e

# Función para extraer valor YAML
extract_yaml_value() {
    local file="$1"
    local key="$2"
    local value=$(grep "^$key:" "$file" | sed 's/^[^:]*: *//' | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")
    echo "$value"
}

# Recopilar métricas
CURRENT_DATE=$(date +"%Y-%m-%d")
CURRENT_TIME=$(date +"%H:%M UTC")

# Conteos generales
ACTIVE_COUNT=$(find tickets/active -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
COMPLETED_COUNT=$(find tickets/completed -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
CANCELLED_COUNT=$(find tickets/cancelled -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
TOTAL_COUNT=$((ACTIVE_COUNT + COMPLETED_COUNT + CANCELLED_COUNT))

# Conteos por prioridad (solo activos)
HIGH_PRIORITY=0
MEDIUM_PRIORITY=0
LOW_PRIORITY=0

for file in tickets/active/*.md; do
    if [ -f "$file" ]; then
        priority=$(extract_yaml_value "$file" "priority")
        case "$priority" in
            "Alta") HIGH_PRIORITY=$((HIGH_PRIORITY + 1)) ;;
            "Media") MEDIUM_PRIORITY=$((MEDIUM_PRIORITY + 1)) ;;
            "Baja") LOW_PRIORITY=$((LOW_PRIORITY + 1)) ;;
        esac
    fi
done

# Servicios con más trabajo
declare -a services=("mb-business" "mb-commerce-channels" "mb-frontend" "mb-cloud-automation" "mb-db" "mb-agents" "test-service")
TOP_SERVICE=""
TOP_SERVICE_COUNT=0

for service in "${services[@]}"; do
    count=0
    for file in tickets/active/*.md; do
        if [ -f "$file" ]; then
            file_service=$(extract_yaml_value "$file" "service")
            if [ "$file_service" = "$service" ]; then
                count=$((count + 1))
            fi
        fi
    done
    if [ $count -gt $TOP_SERVICE_COUNT ]; then
        TOP_SERVICE_COUNT=$count
        TOP_SERVICE=$service
    fi
done

# Calcular porcentaje de completados
if [ $TOTAL_COUNT -gt 0 ]; then
    COMPLETION_RATE=$(( (COMPLETED_COUNT * 100) / TOTAL_COUNT ))
else
    COMPLETION_RATE=0
fi

# Generar sección de métricas para README
cat > .metrics-section.md << EOF
## 📊 Estado Actual del Sistema

> **Última actualización**: $CURRENT_DATE a las $CURRENT_TIME  
> **Dashboard completo**: [Ver métricas detalladas](dashboard.html)

### 🎯 Métricas Principales

<div align="center">

| 📈 Métrica | 🔢 Valor | 📊 Estado |
|------------|----------|-----------|
| **Tickets Activos** | **$ACTIVE_COUNT** | $([ $ACTIVE_COUNT -le 5 ] && echo "🟢 Bajo" || echo "🟡 Normal") |
| **Tickets Completados** | $COMPLETED_COUNT | 🔵 Total |
| **Tickets Cancelados** | $CANCELLED_COUNT | 🔴 Total |
| **Tasa de Finalización** | $COMPLETION_RATE% | $([ $COMPLETION_RATE -ge 70 ] && echo "🟢 Buena" || echo "🟡 Mejorable") |

</div>

### ⚡ Distribución por Prioridad (Activos)

\`\`\`
🔴 Alta:    $HIGH_PRIORITY tickets$([ $HIGH_PRIORITY -gt 3 ] && echo " ⚠️ " || echo "")
🟡 Media:   $MEDIUM_PRIORITY tickets  
🟢 Baja:    $LOW_PRIORITY tickets
\`\`\`

### 🔧 Servicio con Mayor Carga
$([ $TOP_SERVICE_COUNT -gt 0 ] && echo "**$TOP_SERVICE** con $TOP_SERVICE_COUNT tickets activos" || echo "Sin carga concentrada")

### 🚀 Acciones Rápidas

\`\`\`bash
# Ver todos los tickets activos
./scripts/find-tickets.sh --estado active --stats

# Dashboard actualizado
./scripts/update-and-open-dashboard.sh

# Crear nuevo ticket
./scripts/create-ticket.sh nombre_del_feature [servicio]
\`\`\`

---
EOF

echo "✅ Métricas generadas en .metrics-section.md" 