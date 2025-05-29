# 📑 Índice de Tickets MB

Navegación centralizada del sistema de tickets con metadata estructurada y métricas automáticas.

## 🔧 Comandos Rápidos

```bash
# Ver dashboard de métricas
./scripts/generate-dashboard.sh && open dashboard.html

# Buscar tickets activos
./scripts/find-tickets.sh --estado active --stats

# Crear nuevo ticket
./scripts/create-ticket.sh nombre_del_feature [servicio]
```

## 📊 Estado Actual del Sistema

### Tickets Activos
```bash
./scripts/find-tickets.sh --estado active
```

### Por Prioridad
```bash
# Alta prioridad
./scripts/find-tickets.sh --estado active --prioridad Alta

# Media prioridad  
./scripts/find-tickets.sh --estado active --prioridad Media

# Baja prioridad
./scripts/find-tickets.sh --estado active --prioridad Baja
```

### Por Servicio
```bash
# mb-business
./scripts/find-tickets.sh --servicio mb-business --estado active

# mb-commerce-channels
./scripts/find-tickets.sh --servicio mb-commerce-channels --estado active

# mb-frontend
./scripts/find-tickets.sh --servicio mb-frontend --estado active

# mb-cloud-automation
./scripts/find-tickets.sh --servicio mb-cloud-automation --estado active

# mb-db
./scripts/find-tickets.sh --servicio mb-db --estado active

# mb-agents
./scripts/find-tickets.sh --servicio mb-agents --estado active

# test-service
./scripts/find-tickets.sh --servicio test-service --estado active
```

## 🎯 Filtros Avanzados

### Por Asignación
```bash
# Tickets sin asignar
./scripts/find-tickets.sh --assignee "Por asignar" --estado active

# Tickets de un desarrollador
./scripts/find-tickets.sh --assignee "Nombre Desarrollador" --estado active
```

### Por Tags
```bash
# Tags específicos
./scripts/find-tickets.sh --tags "security,authentication"
./scripts/find-tickets.sh --tags "performance,cache"
./scripts/find-tickets.sh --tags "api,integration"
```

### Búsqueda de Texto
```bash
# Buscar en contenido
./scripts/find-tickets.sh --query "payment gateway"
./scripts/find-tickets.sh --query "user authentication"
./scripts/find-tickets.sh --query "database migration"
```

## 📈 Reportes y Métricas

### Dashboard HTML
```bash
# Generar dashboard completo
./scripts/generate-dashboard.sh

# Dashboard personalizado
./scripts/generate-dashboard.sh weekly-report.html
```

### Estadísticas por Comandos
```bash
# Estadísticas generales
./scripts/find-tickets.sh --estado active --stats

# Por servicio específico
./scripts/find-tickets.sh --servicio mb-business --stats

# Por prioridad
./scripts/find-tickets.sh --prioridad Alta --stats
```

### Exportación JSON
```bash
# Todos los tickets activos
./scripts/find-tickets.sh --estado active --json > active-tickets.json

# Tickets completados
./scripts/find-tickets.sh --estado completed --json > completed-tickets.json

# Por servicio
./scripts/find-tickets.sh --servicio mb-business --json > mb-business-tickets.json
```

## 🔄 Gestión de Estados

### Mover Tickets
```bash
# A completado
./scripts/move-ticket.sh tickets/active/TIMESTAMP_ticket_name.md completed

# A cancelado
./scripts/move-ticket.sh tickets/active/TIMESTAMP_ticket_name.md cancelled

# Reactivar
./scripts/move-ticket.sh tickets/completed/TIMESTAMP_ticket_name.md active
```

## 🏷️ Estructura de Metadata (YAML Frontmatter)

Cada ticket contiene metadata estructurada:

```yaml
---
id: "20250529020058"                    # ID único con timestamp
service: "mb-business"                  # Servicio afectado
priority: "Alta"                        # Alta/Media/Baja
estimation: "M"                         # XS/S/M/L/XL
assignee: "Desarrollador Nombre"        # Responsable
created: "2025-05-29"                   # Fecha de creación
target_date: "2025-06-05"               # Fecha objetivo
status: "En análisis"                   # Estado actual
tags: ["security", "api", "validation"] # Tags para categorización
dependencies: ["20250528141230"]        # IDs de tickets dependientes
related_tickets: ["20250530093045"]     # Tickets relacionados
external_apis: ["stripe", "paypal"]     # APIs externas involucradas
---
```

## 📚 Recursos y Documentación

### Enlaces Principales
- [📊 Dashboard](dashboard.html) - Métricas en tiempo real
- [📖 README Principal](README.md) - Documentación completa
- [📋 Directrices](docs/guidelines.md) - Principios del sistema
- [🌟 Mejores Prácticas](docs/best-practices.md) - Guías por servicio

### Plantillas y Ejemplos
- [📝 Plantilla de Ticket](templates/ticket-template.md) - Con YAML frontmatter
- [🎯 Ejemplo Completo](tickets/active/20250529020058_create_customer_channel_restrictions.md)

## 🤖 Automatización Disponible

### Scripts Principales
1. **create-ticket.sh** - Creación automática con metadata
2. **find-tickets.sh** - Búsqueda avanzada y estadísticas  
3. **move-ticket.sh** - Gestión de estados
4. **generate-dashboard.sh** - Dashboard HTML automático

### Casos de Uso Frecuentes
```bash
# Revisión diaria
./scripts/find-tickets.sh --estado active --stats

# Planificación semanal  
./scripts/find-tickets.sh --prioridad Alta --assignee "Tu Nombre" --stats

# Reporte mensual
./scripts/generate-dashboard.sh monthly-$(date +%Y-%m).html

# Seguimiento por servicio
./scripts/find-tickets.sh --servicio mb-frontend --estado active
```

## 🔍 Búsquedas Útiles

### Tickets Críticos
```bash
./scripts/find-tickets.sh --prioridad Alta --estado active --stats
```

### Trabajo Pendiente por Desarrollador
```bash  
./scripts/find-tickets.sh --assignee "Nombre" --estado active --json
```

### Features por Release
```bash
./scripts/find-tickets.sh --tags "v2.1,release" --estado completed
```

### Dependencias Bloqueantes
```bash
./scripts/find-tickets.sh --tags "blocker,dependency" --estado active
```

---

💡 **Tip**: Usa `--stats` en cualquier búsqueda para obtener métricas detalladas.

🎯 **Actualización**: Este índice se mantiene automáticamente mediante los scripts del sistema. 