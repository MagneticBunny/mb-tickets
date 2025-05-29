# 🎫 Sistema de Tickets MB

> **Sistema de gestión de tickets para el desarrollo de nuevos features en el ecosistema de microservicios MB**

## 📊 Estado Actual del Sistema

> **Última actualización**: 2025-05-29 a las 03:30 UTC  
> **Dashboard completo**: [Ver métricas detalladas](dashboard.html)

### 🎯 Métricas Principales

<div align="center">

| 📈 Métrica | 🔢 Valor | 📊 Estado |
|------------|----------|-----------|
| **Tickets Activos** | **2** | 🟢 Bajo |
| **Tickets Completados** | 0 | 🔵 Total |
| **Tickets Cancelados** | 0 | 🔴 Total |
| **Tasa de Finalización** | 0% | 🟡 Mejorable |

</div>

### ⚡ Distribución por Prioridad (Activos)

```
🔴 Alta:    1 tickets
🟡 Media:   0 tickets  
🟢 Baja:    0 tickets
```

### 🔧 Servicio con Mayor Carga
**mb-business** con 1 tickets activos

### 🚀 Acciones Rápidas

```bash
# Ver todos los tickets activos
./scripts/find-tickets.sh --estado active --stats

# Dashboard actualizado
./scripts/update-and-open-dashboard.sh

# Crear nuevo ticket
./scripts/create-ticket.sh nombre_del_feature [servicio]
```

---

## 🏢 **Para Project Managers y Stakeholders**

### 📈 **Visibilidad en Tiempo Real**
- **Dashboard Web**: [https://tu-org.github.io/mb-tickets](dashboard.html) (se actualiza automáticamente)
- **GitHub Repository**: Descripción del repo muestra métricas en vivo
- **Métricas Automatizadas**: Se actualizan cada commit y diariamente

### 🎯 **KPIs Clave Monitoreados**
- **Throughput**: Tickets completados por sprint
- **Lead Time**: Tiempo promedio de ticket
- **Workload**: Distribución de trabajo por servicio
- **Prioridades**: Balance entre tickets críticos y menores

### 🔄 **Automatización Empresarial**
- ✅ **Auto-actualización**: GitHub Actions mantiene métricas frescas
- ✅ **Notificaciones**: Cambios automáticos en descripción del repositorio
- ✅ **Reportes**: Dashboard accesible desde cualquier dispositivo
- ✅ **Historial**: Todas las métricas están versionadas con Git

---

## 🔧 **Para Desarrolladores**

### 🎯 Filosofía: "Documentation as Code"

Este sistema adopta el principio de **"Documentation as Code"**, donde la documentación técnica se gestiona como código:
- ✅ **Versionado**: Todos los tickets están bajo control de versiones con Git
- ✅ **Estructura**: Plantillas consistentes y metadata estructurada (YAML frontmatter)
- ✅ **Trazabilidad**: Cada ticket tiene un ID único con timestamp
- ✅ **Escalabilidad**: Fácil búsqueda, filtrado y generación de reportes automáticos
- ✅ **Simplicidad**: Sin dependencias externas, solo archivos Markdown

### 🏷️ YAML Frontmatter
Cada ticket incluye metadata estructurada al inicio:
```yaml
---
id: "20250529020058"
service: "mb-business"
priority: "Alta"
estimation: "M"
assignee: "[Por asignar]"
created: "2025-05-29"
target_date: "2025-06-05"
status: "En análisis"
tags: ["restricciones", "canal", "validacion"]
dependencies: ["20250528141230"]
related_tickets: ["20250530093045"]
external_apis: []
---
```

### 🚀 Comandos Esenciales

#### Crear un Nuevo Ticket
```bash
# Crear ticket básico
./scripts/create-ticket.sh nombre_del_feature

# Crear ticket para servicio específico
./scripts/create-ticket.sh implement_payment_gateway mb-commerce-channels
```

#### Buscar Tickets
```bash
# Buscar por metadata
./scripts/find-tickets.sh --estado active --prioridad Alta
./scripts/find-tickets.sh --servicio mb-business --assignee "Juan Pérez"
./scripts/find-tickets.sh --tags "cache,validacion" --stats

# Búsqueda de texto
./scripts/find-tickets.sh --query "restricciones" --estado active

# Obtener estadísticas
./scripts/find-tickets.sh --estado active --stats

# Salida JSON para integración
./scripts/find-tickets.sh --servicio mb-business --json
```

#### Dashboard y Métricas
```bash
# Dashboard actualizado (LOCAL)
./scripts/update-and-open-dashboard.sh

# Generar dashboard específico
./scripts/generate-dashboard.sh weekly-report.html

# Solo generar métricas
./scripts/generate-readme-metrics.sh
```

---

## 🏗️ Estructura del Proyecto

```
mb-tickets/
├── README.md                    # Este archivo (con métricas en vivo)
├── dashboard.html              # Dashboard generado automáticamente
├── TICKET_INDEX.md             # Índice navegable de tickets
├── templates/
│   └── ticket-template.md      # Plantilla con YAML frontmatter
├── scripts/
│   ├── create-ticket.sh        # Crear tickets con metadata automática
│   ├── find-tickets.sh         # Búsqueda avanzada por metadata
│   ├── move-ticket.sh          # Mover tickets entre estados
│   ├── generate-dashboard.sh   # Generar dashboard HTML
│   ├── update-and-open-dashboard.sh  # 🆕 Actualizar y abrir (LOCAL)
│   └── generate-readme-metrics.sh    # 🆕 Métricas para README
├── tickets/
│   ├── active/                 # Tickets en desarrollo
│   ├── completed/              # Tickets terminados
│   └── cancelled/              # Tickets cancelados
├── docs/
│   ├── guidelines.md           # Principios y directrices
│   └── best-practices.md       # Mejores prácticas por servicio
└── .github/workflows/
    └── update-dashboard.yml    # 🆕 Automatización GitHub Actions
```

## 🔧 Microservicios del Ecosistema

| Servicio | Descripción | Responsabilidades Principales |
|----------|-------------|------------------------------|
| **mb-business** | Lógica de negocio central | Reglas de negocio, validaciones, workflows |
| **mb-commerce-channels** | Gestión de canales de comercio | APIs de venta, integraciones, canales |
| **mb-frontend** | Interfaz de usuario | React, UX/UI, aplicaciones web |
| **mb-cloud-automation** | Infraestructura y DevOps | CI/CD, monitoreo, escalabilidad |
| **mb-db** | Gestión de base de datos | Esquemas, migraciones, optimización |
| **mb-agents** | Servicios de agentes | Automatización, bots, integración |
| **test-service** | Testing y QA | Tests automatizados, validación |

## 📋 Flujo de Trabajo

### 1. Análisis del Feature
```bash
# Crear ticket inicial
./scripts/create-ticket.sh implement_new_feature mb-business

# Editar y completar información
code tickets/active/20250529XXXXXX_implement_new_feature.md
```

### 2. Identificar Dependencias
- Actualizar `dependencies:` en YAML frontmatter
- Crear tickets relacionados para otros servicios
- Documentar `related_tickets:` 

### 3. Desarrollo y Seguimiento
```bash
# Monitorear progreso
./scripts/find-tickets.sh --assignee "Developer Name" --stats

# Actualizar dashboard LOCAL
./scripts/update-and-open-dashboard.sh
```

### 4. Completar Feature
```bash
# Marcar como completado
./scripts/move-ticket.sh tickets/active/TICKET_FILE.md completed

# Las métricas se actualizarán automáticamente en GitHub
```

## 🎨 Ejemplos de Uso

### Búsquedas Avanzadas
```bash
# Tickets críticos pendientes
./scripts/find-tickets.sh --estado active --prioridad Alta --stats

# Features de un desarrollador específico
./scripts/find-tickets.sh --assignee "Maria Rodriguez" --estado active

# Tickets con tags específicos
./scripts/find-tickets.sh --tags "security,authentication" --servicio mb-business

# Búsqueda de texto en contenido
./scripts/find-tickets.sh --query "payment gateway" --estado active
```

### Generación de Reportes
```bash
# Dashboard LOCAL actualizado
./scripts/update-and-open-dashboard.sh

# Dashboard específico
./scripts/generate-dashboard.sh monthly-report.html

# Exportar datos en JSON
./scripts/find-tickets.sh --estado completed --json > completed-tickets.json

# Estadísticas por servicio
./scripts/find-tickets.sh --servicio mb-frontend --stats
```

## 🔄 Automatización y Configuración

### 🔧 **Uso Local (Desarrolladores)**
```bash
# Dashboard actualizado en un comando
./scripts/update-and-open-dashboard.sh

# Se abre automáticamente en el navegador
# Perfecto para desarrollo diario
```

### ⚙️ **Automatización Empresarial (GitHub Actions)**
- ✅ **Trigger**: Cualquier cambio en `tickets/` o `scripts/`
- ✅ **Horario**: Diariamente a las 8:00 AM UTC (días laborales)
- ✅ **Manual**: Ejecutable desde GitHub UI
- ✅ **Deploy**: GitHub Pages para acceso web público
- ✅ **Actualización**: README y descripción de repositorio automáticos

### 📊 **Métricas en Vivo**
- **Repository Description**: Actualizada automáticamente con métricas
- **GitHub Pages**: Dashboard público accesible 24/7
- **README**: Métricas actualizadas en cada commit
- **Badge Dinámico**: Estado visible desde cualquier página de GitHub

## 🛠️ Configuración Avanzada

### Personalizar Metadata
Edita `templates/ticket-template.md` para añadir campos específicos:
```yaml
---
# Campos estándar
id: ""
service: ""
priority: ""
# Campos personalizados
epic: ""
client: ""
release_version: ""
---
```

### Integración con Herramientas
```bash
# Integrar con Slack
./scripts/find-tickets.sh --prioridad Alta --json | jq '.[] | .title' | slack-notify

# Sincronizar con Jira
./scripts/find-tickets.sh --estado completed --json | python sync-to-jira.py

# Generar changelog automático
./scripts/find-tickets.sh --estado completed --json | python generate-changelog.py
```

## 🔗 Enlaces Útiles

- [📊 Dashboard Web](dashboard.html) - Métricas en tiempo real
- [📖 Directrices Completas](docs/guidelines.md) - Principios del sistema
- [🌟 Mejores Prácticas](docs/best-practices.md) - Guías por servicio
- [📑 Índice de Tickets](TICKET_INDEX.md) - Navegación detallada

---

## 💡 **Quick Start**

### Para PMs/Stakeholders:
1. **Ver estado actual**: Métricas en la parte superior de este README
2. **Dashboard completo**: [Clic aquí](dashboard.html)
3. **Acceso web**: GitHub Pages URL (configurar en Settings > Pages)

### Para Desarrolladores:
1. **Crear ticket**: `./scripts/create-ticket.sh nuevo_feature mb-business`
2. **Ver dashboard**: `./scripts/update-and-open-dashboard.sh`
3. **Buscar**: `./scripts/find-tickets.sh --estado active --stats`

---

💡 **Consejo**: Las métricas se actualizan automáticamente. Para forzar actualización local usa `./scripts/update-and-open-dashboard.sh`

🎯 **Objetivo**: Gestión eficiente y escalable de features en el ecosistema MB con máxima visibilidad y trazabilidad tanto para equipos técnicos como para stakeholders empresariales. 