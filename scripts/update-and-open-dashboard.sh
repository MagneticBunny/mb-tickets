#!/bin/bash

# Script para actualizar dashboard y abrirlo automáticamente
# Uso: ./update-and-open-dashboard.sh [archivo_salida]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Archivo de salida
OUTPUT_FILE="${1:-dashboard.html}"

echo -e "${BLUE}🔄 Actualizando Dashboard de Tickets MB...${NC}"
echo ""

# Ejecutar script de generación
if [ -f "scripts/generate-dashboard.sh" ]; then
    echo -e "${YELLOW}📊 Regenerando métricas...${NC}"
    ./scripts/generate-dashboard.sh "$OUTPUT_FILE"
    echo ""
else
    echo -e "${RED}❌ Error: No se encontró scripts/generate-dashboard.sh${NC}"
    exit 1
fi

# Verificar que se generó el archivo
if [ ! -f "$OUTPUT_FILE" ]; then
    echo -e "${RED}❌ Error: No se pudo generar $OUTPUT_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dashboard actualizado exitosamente${NC}"
echo ""

# Abrir en el navegador
echo -e "${BLUE}🌐 Abriendo dashboard en el navegador...${NC}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$OUTPUT_FILE"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open &> /dev/null; then
        xdg-open "$OUTPUT_FILE"
    elif command -v firefox &> /dev/null; then
        firefox "$OUTPUT_FILE"
    elif command -v google-chrome &> /dev/null; then
        google-chrome "$OUTPUT_FILE"
    else
        echo -e "${YELLOW}⚠️  No se pudo detectar navegador. Abre manualmente: $OUTPUT_FILE${NC}"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows
    start "$OUTPUT_FILE"
else
    echo -e "${YELLOW}⚠️  SO no detectado. Abre manualmente: $OUTPUT_FILE${NC}"
fi

echo ""
echo -e "${GREEN}🎯 ¡Listo! El dashboard se actualizó y abrió automáticamente.${NC}"
echo ""
echo -e "${BLUE}💡 Consejos:${NC}"
echo "   • Ejecuta este script cuando quieras ver métricas actualizadas"
echo "   • Agrégalo a tu workflow diario: \`./scripts/update-and-open-dashboard.sh\`"
echo "   • Para reportes específicos: \`./scripts/update-and-open-dashboard.sh reporte-semanal.html\`" 