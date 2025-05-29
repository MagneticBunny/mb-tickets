#!/bin/bash

# Script para generar dashboard HTML con métricas básicas
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
        
        .progress-bar {
            width: 100px;
            height: 6px;
            background: #dee2e6;
            border-radius: 3px;
            overflow: hidden;
            margin-left: 10px;
        }
        
        .progress-fill {
            height: 100%;
            transition: width 0.3s ease;
        }
        
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #6c757d;
            border-top: 1px solid #dee2e6;
        }
        
        .refresh-btn {
            background: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            margin-top: 10px;
            transition: background 0.3s ease;
        }
        
        .refresh-btn:hover {
            background: #0056b3;
        }
        
        @media (max-width: 768px) {
            .chart-grid {
                grid-template-columns: 1fr;
            }
            .stats-grid {
                grid-template-columns: 1fr;
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
        
        <div class="footer">
            <p>🎯 Sistema de Tickets MB - "Documentation as Code"</p>
            <button class="refresh-btn" onclick="location.reload()">🔄 Actualizar Dashboard</button>
        </div>
    </div>
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

# Limpiar archivo temporal
rm -f "$OUTPUT_FILE.bak"

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