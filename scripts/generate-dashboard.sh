#!/bin/bash

# Script para generar dashboard HTML con métricas y acordeón de tickets
# Uso: ./generate-dashboard.sh [archivo_salida]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Archivo de salida por defecto
OUTPUT_FILE="${1:-dashboard.html}"

echo -e "${BLUE}Generando dashboard de tickets...${NC}"

# Función para extraer valor YAML
extract_yaml_value() {
    local file="$1"
    local key="$2"
    local value=$(grep "^$key:" "$file" | sed 's/^[^:]*: *//' | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")
    echo "$value"
}

# Función para extraer título del ticket
extract_title() {
    local file="$1"
    # Buscar el primer título H1 o H2 después del frontmatter
    local title=$(awk '/^---$/{flag++} flag==2 && /^#/ {gsub(/^#+\s*/, ""); print; exit}' "$file")
    if [ -z "$title" ]; then
        # Si no hay título, usar el nombre del archivo sin extensión
        title=$(basename "$file" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
    fi
    echo "$title"
}

# Función para generar HTML de tickets por estado
generate_tickets_html() {
    local estado="$1"
    local directorio="$2"
    local html=""
    
    if [ -d "$directorio" ]; then
        for file in "$directorio"/*.md; do
            if [ -f "$file" ]; then
                local id=$(extract_yaml_value "$file" "id")
                local service=$(extract_yaml_value "$file" "service")
                local priority=$(extract_yaml_value "$file" "priority")
                local assignee=$(extract_yaml_value "$file" "assignee")
                local created=$(extract_yaml_value "$file" "created")
                local estimation=$(extract_yaml_value "$file" "estimation")
                local title=$(extract_title "$file")
                local filename=$(basename "$file")
                
                # Determinar icono de prioridad
                local priority_icon="🟡"
                case "$priority" in
                    "Alta") priority_icon="🔴" ;;
                    "Media") priority_icon="🟡" ;;
                    "Baja") priority_icon="🟢" ;;
                esac
                
                html="$html
                <div class=\"ticket-item\">
                    <div class=\"ticket-header\">
                        <div class=\"ticket-title\">
                            <span class=\"ticket-id\">#$id</span>
                            <span class=\"ticket-name\">$title</span>
                        </div>
                        <div class=\"ticket-priority\">$priority_icon $priority</div>
                    </div>
                    <div class=\"ticket-details\">
                        <div class=\"ticket-meta\">
                            <span class=\"meta-item\"><strong>Servicio:</strong> $service</span>
                            <span class=\"meta-item\"><strong>Asignado:</strong> $assignee</span>
                            <span class=\"meta-item\"><strong>Creado:</strong> $created</span>
                            <span class=\"meta-item\"><strong>Estimación:</strong> $estimation</span>
                        </div>
                        <div class=\"ticket-file\">📄 $filename</div>
                    </div>
                </div>"
            fi
        done
    fi
    
    echo "$html"
}

# Función para contar tickets por criterio
count_by_yaml_field() {
    local field="$1"
    local value="$2"
    local count=0
    
    for file in tickets/active/*.md; do
        if [ -f "$file" ]; then
            local file_value=$(extract_yaml_value "$file" "$field")
            if [ "$file_value" = "$value" ]; then
                count=$((count + 1))
            fi
        fi
    done
    echo $count
}

# Recopilar métricas
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Conteos generales
ACTIVE_COUNT=$(find tickets/active -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
COMPLETED_COUNT=$(find tickets/completed -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
CANCELLED_COUNT=$(find tickets/cancelled -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
TOTAL_COUNT=$((ACTIVE_COUNT + COMPLETED_COUNT + CANCELLED_COUNT))

# Conteos por prioridad
HIGH_PRIORITY=$(count_by_yaml_field "priority" "Alta")
MEDIUM_PRIORITY=$(count_by_yaml_field "priority" "Media")
LOW_PRIORITY=$(count_by_yaml_field "priority" "Baja")

# Conteos por servicio
MB_BUSINESS=$(count_by_yaml_field "service" "mb-business")
MB_COMMERCE=$(count_by_yaml_field "service" "mb-commerce-channels")
MB_FRONTEND=$(count_by_yaml_field "service" "mb-frontend")
MB_CLOUD=$(count_by_yaml_field "service" "mb-cloud-automation")
MB_DB=$(count_by_yaml_field "service" "mb-db")
MB_AGENTS=$(count_by_yaml_field "service" "mb-agents")
TEST_SERVICE=$(count_by_yaml_field "service" "test-service")

# Generar HTML de tickets por estado
ACTIVE_TICKETS_HTML=$(generate_tickets_html "Activos" "tickets/active")
COMPLETED_TICKETS_HTML=$(generate_tickets_html "Completados" "tickets/completed")
CANCELLED_TICKETS_HTML=$(generate_tickets_html "Cancelados" "tickets/cancelled")

# Generar HTML
cat > "$OUTPUT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Sistema de Tickets MB</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header .subtitle {
            opacity: 0.9;
            font-size: 1.1em;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            padding: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            border-left: 4px solid;
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card.primary { border-left-color: #3498db; }
        .stat-card.success { border-left-color: #27ae60; }
        .stat-card.warning { border-left-color: #f39c12; }
        .stat-card.danger { border-left-color: #e74c3c; }
        .stat-card.info { border-left-color: #9b59b6; }
        
        .stat-number {
            font-size: 3em;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #7f8c8d;
            font-size: 1.1em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .chart-section {
            padding: 30px;
            border-top: 1px solid #ecf0f1;
        }
        
        .chart-title {
            font-size: 1.5em;
            margin-bottom: 20px;
            color: #2c3e50;
            text-align: center;
        }
        
        .chart-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        
        .chart-container {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
        }
        
        .chart-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #dee2e6;
        }
        
        .chart-item:last-child {
            border-bottom: none;
        }
        
        .chart-label {
            font-weight: 500;
        }
        
        .chart-value {
            font-weight: bold;
            color: #495057;
        }
        
        /* Estilos del Acordeón */
        .tickets-section {
            padding: 30px;
            border-top: 1px solid #ecf0f1;
        }
        
        .section-title {
            font-size: 1.8em;
            margin-bottom: 25px;
            color: #2c3e50;
            text-align: center;
        }
        
        .accordion {
            margin-bottom: 15px;
        }
        
        .accordion-header {
            background: linear-gradient(135deg, #34495e 0%, #2c3e50 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 600;
            font-size: 1.1em;
        }
        
        .accordion-header:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .accordion-header.active {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
        }
        
        .accordion-toggle {
            font-size: 1.2em;
            transition: transform 0.3s ease;
        }
        
        .accordion-header.active .accordion-toggle {
            transform: rotate(180deg);
        }
        
        .accordion-content {
            background: #f8f9fa;
            border-radius: 0 0 10px 10px;
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
        }
        
        .accordion-content.active {
            max-height: 2000px;
        }
        
        .accordion-body {
            padding: 20px;
        }
        
        .ticket-item {
            background: white;
            border-radius: 8px;
            margin-bottom: 15px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s ease;
        }
        
        .ticket-item:hover {
            transform: translateY(-2px);
        }
        
        .ticket-header {
            padding: 15px 20px;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .ticket-title {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .ticket-id {
            background: #007bff;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            font-weight: bold;
        }
        
        .ticket-name {
            font-weight: 600;
            color: #2c3e50;
        }
        
        .ticket-priority {
            font-weight: 500;
            padding: 5px 10px;
            border-radius: 15px;
            background: #f8f9fa;
            font-size: 0.9em;
        }
        
        .ticket-details {
            padding: 15px 20px;
        }
        
        .ticket-meta {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 10px;
            margin-bottom: 10px;
        }
        
        .meta-item {
            color: #6c757d;
            font-size: 0.9em;
        }
        
        .ticket-file {
            color: #007bff;
            font-size: 0.9em;
            font-family: monospace;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #6c757d;
        }
        
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #6c757d;
            border-top: 1px solid #dee2e6;
        }
        
        @media (max-width: 768px) {
            .chart-grid {
                grid-template-columns: 1fr;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .ticket-meta {
                grid-template-columns: 1fr;
            }
            .accordion-header {
                font-size: 1em;
                padding: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Dashboard de Tickets</h1>
            <div class="subtitle">Sistema de Gestión MB - Actualizado: TIMESTAMP_PLACEHOLDER</div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card primary">
                <div class="stat-number">ACTIVE_COUNT_PLACEHOLDER</div>
                <div class="stat-label">Tickets Activos</div>
            </div>
            
            <div class="stat-card success">
                <div class="stat-number">COMPLETED_COUNT_PLACEHOLDER</div>
                <div class="stat-label">Completados</div>
            </div>
            
            <div class="stat-card danger">
                <div class="stat-number">CANCELLED_COUNT_PLACEHOLDER</div>
                <div class="stat-label">Cancelados</div>
            </div>
            
            <div class="stat-card info">
                <div class="stat-number">TOTAL_COUNT_PLACEHOLDER</div>
                <div class="stat-label">Total Tickets</div>
            </div>
        </div>
        
        <div class="chart-section">
            <div class="chart-title">📈 Distribución Detallada</div>
            <div class="chart-grid">
                <div class="chart-container">
                    <h3 style="margin-bottom: 15px; color: #495057;">⚡ Por Prioridad</h3>
                    <div class="chart-item">
                        <span class="chart-label">🔴 Alta</span>
                        <span class="chart-value">HIGH_PRIORITY_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">🟡 Media</span>
                        <span class="chart-value">MEDIUM_PRIORITY_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">🟢 Baja</span>
                        <span class="chart-value">LOW_PRIORITY_PLACEHOLDER</span>
                    </div>
                </div>
                
                <div class="chart-container">
                    <h3 style="margin-bottom: 15px; color: #495057;">🔧 Por Servicio</h3>
                    <div class="chart-item">
                        <span class="chart-label">mb-business</span>
                        <span class="chart-value">MB_BUSINESS_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">mb-commerce-channels</span>
                        <span class="chart-value">MB_COMMERCE_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">mb-frontend</span>
                        <span class="chart-value">MB_FRONTEND_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">mb-cloud-automation</span>
                        <span class="chart-value">MB_CLOUD_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">mb-db</span>
                        <span class="chart-value">MB_DB_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">mb-agents</span>
                        <span class="chart-value">MB_AGENTS_PLACEHOLDER</span>
                    </div>
                    <div class="chart-item">
                        <span class="chart-label">test-service</span>
                        <span class="chart-value">TEST_SERVICE_PLACEHOLDER</span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="tickets-section">
            <h2 class="section-title">🎫 Listado de Tickets por Estado</h2>
            
            <!-- Tickets Activos -->
            <div class="accordion">
                <div class="accordion-header" onclick="toggleAccordion('active')">
                    <span>🟢 Tickets Activos (ACTIVE_COUNT_PLACEHOLDER)</span>
                    <span class="accordion-toggle">▼</span>
                </div>
                <div id="active" class="accordion-content">
                    <div class="accordion-body">
                        ACTIVE_TICKETS_HTML_PLACEHOLDER
                    </div>
                </div>
            </div>
            
            <!-- Tickets Completados -->
            <div class="accordion">
                <div class="accordion-header" onclick="toggleAccordion('completed')">
                    <span>✅ Tickets Completados (COMPLETED_COUNT_PLACEHOLDER)</span>
                    <span class="accordion-toggle">▼</span>
                </div>
                <div id="completed" class="accordion-content">
                    <div class="accordion-body">
                        COMPLETED_TICKETS_HTML_PLACEHOLDER
                    </div>
                </div>
            </div>
            
            <!-- Tickets Cancelados -->
            <div class="accordion">
                <div class="accordion-header" onclick="toggleAccordion('cancelled')">
                    <span>❌ Tickets Cancelados (CANCELLED_COUNT_PLACEHOLDER)</span>
                    <span class="accordion-toggle">▼</span>
                </div>
                <div id="cancelled" class="accordion-content">
                    <div class="accordion-body">
                        CANCELLED_TICKETS_HTML_PLACEHOLDER
                    </div>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>🎯 Sistema de Tickets MB - "Documentation as Code"</p>
        </div>
    </div>
    
    <script>
        function toggleAccordion(sectionId) {
            const content = document.getElementById(sectionId);
            const header = content.previousElementSibling;
            
            // Toggle active class
            header.classList.toggle('active');
            content.classList.toggle('active');
        }
        
        // Auto-abrir la sección de tickets activos si hay contenido
        document.addEventListener('DOMContentLoaded', function() {
            const activeCount = ACTIVE_COUNT_PLACEHOLDER;
            if (activeCount > 0) {
                toggleAccordion('active');
            }
        });
    </script>
</body>
</html>
EOF

# Reemplazar placeholders con valores reales
sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$CURRENT_DATE/g" "$OUTPUT_FILE"
sed -i.bak "s/ACTIVE_COUNT_PLACEHOLDER/$ACTIVE_COUNT/g" "$OUTPUT_FILE"
sed -i.bak "s/COMPLETED_COUNT_PLACEHOLDER/$COMPLETED_COUNT/g" "$OUTPUT_FILE"
sed -i.bak "s/CANCELLED_COUNT_PLACEHOLDER/$CANCELLED_COUNT/g" "$OUTPUT_FILE"
sed -i.bak "s/TOTAL_COUNT_PLACEHOLDER/$TOTAL_COUNT/g" "$OUTPUT_FILE"
sed -i.bak "s/HIGH_PRIORITY_PLACEHOLDER/$HIGH_PRIORITY/g" "$OUTPUT_FILE"
sed -i.bak "s/MEDIUM_PRIORITY_PLACEHOLDER/$MEDIUM_PRIORITY/g" "$OUTPUT_FILE"
sed -i.bak "s/LOW_PRIORITY_PLACEHOLDER/$LOW_PRIORITY/g" "$OUTPUT_FILE"
sed -i.bak "s/MB_BUSINESS_PLACEHOLDER/$MB_BUSINESS/g" "$OUTPUT_FILE"
sed -i.bak "s/MB_COMMERCE_PLACEHOLDER/$MB_COMMERCE/g" "$OUTPUT_FILE"
sed -i.bak "s/MB_FRONTEND_PLACEHOLDER/$MB_FRONTEND/g" "$OUTPUT_FILE"
sed -i.bak "s/MB_CLOUD_PLACEHOLDER/$MB_CLOUD/g" "$OUTPUT_FILE"
sed -i.bak "s/MB_DB_PLACEHOLDER/$MB_DB/g" "$OUTPUT_FILE"
sed -i.bak "s/MB_AGENTS_PLACEHOLDER/$MB_AGENTS/g" "$OUTPUT_FILE"
sed -i.bak "s/TEST_SERVICE_PLACEHOLDER/$TEST_SERVICE/g" "$OUTPUT_FILE"

# Limpiar archivo temporal sed
rm -f "$OUTPUT_FILE.bak"

# Reemplazar placeholders de HTML directamente
# Si no hay tickets, mostrar mensaje vacío
if [ -z "$ACTIVE_TICKETS_HTML" ]; then
    ACTIVE_TICKETS_HTML='<div class="empty-state">📭 No hay tickets activos</div>'
fi

if [ -z "$COMPLETED_TICKETS_HTML" ]; then
    COMPLETED_TICKETS_HTML='<div class="empty-state">📭 No hay tickets completados</div>'
fi

if [ -z "$CANCELLED_TICKETS_HTML" ]; then
    CANCELLED_TICKETS_HTML='<div class="empty-state">📭 No hay tickets cancelados</div>'
fi

# Exportar variables para Perl
export ACTIVE_TICKETS_HTML
export COMPLETED_TICKETS_HTML  
export CANCELLED_TICKETS_HTML

# Usar perl para reemplazar contenido multilínea de forma segura
perl -i -pe "
s/ACTIVE_TICKETS_HTML_PLACEHOLDER/\$ENV{ACTIVE_TICKETS_HTML}/g;
s/COMPLETED_TICKETS_HTML_PLACEHOLDER/\$ENV{COMPLETED_TICKETS_HTML}/g;
s/CANCELLED_TICKETS_HTML_PLACEHOLDER/\$ENV{CANCELLED_TICKETS_HTML}/g;
" "$OUTPUT_FILE"

echo -e "${GREEN}✓ Dashboard generado exitosamente: $OUTPUT_FILE${NC}"
echo ""
echo -e "${BLUE}📊 Resumen de métricas:${NC}"
echo "  - Tickets activos: $ACTIVE_COUNT"
echo "  - Tickets completados: $COMPLETED_COUNT"
echo "  - Tickets cancelados: $CANCELLED_COUNT"
echo "  - Total tickets: $TOTAL_COUNT"
echo ""
echo -e "${BLUE}Para ver el dashboard:${NC}"
echo "  open $OUTPUT_FILE"
echo "  # o"
echo "  xdg-open $OUTPUT_FILE" 