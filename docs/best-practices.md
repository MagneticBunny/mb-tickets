# Mejores Prácticas para el Sistema de Tickets

## Creación de Tickets

### Antes de Crear un Ticket

1. **Verificar duplicados**: Buscar si ya existe un ticket similar
2. **Analizar alcance**: Determinar si realmente necesita múltiples tickets
3. **Validar requisitos**: Asegurar que los requisitos están claros
4. **Identificar stakeholders**: Saber quién debe revisar y aprobar

### Durante la Creación

1. **Usar la plantilla**: Siempre partir de `templates/ticket-template.md`
2. **Timestamp único**: Usar `date +"%Y%m%d%H%M%S"` para generar timestamp
3. **Nombre descriptivo**: Seguir convención `[VERBO]_[OBJETO]_[CONTEXTO]`
4. **Completar todas las secciones**: No dejar secciones vacías sin justificación

## Gestión de Dependencias

### Identificación de Dependencias

```markdown
## Matriz de Dependencias Comunes

| Servicio Origen | Servicio Destino | Tipo de Dependencia |
|----------------|------------------|-------------------|
| mb-business | mb-db | Esquema de datos |
| mb-frontend | mb-business | API endpoints |
| mb-commerce-channels | mb-business | Lógica de negocio |
| mb-cloud-automation | Todos | Configuración |
```

### Documentación de Dependencias

**Formato recomendado:**
```markdown
## Dependencias
- **Bloqueantes**: 
  - `20250527023056_create_customer_schema.md` (mb-db)
  - `20250527024512_implement_auth_service.md` (mb-business)
- **Dependientes**: 
  - `20250528141230_frontend_customer_ui.md` (mb-frontend)
- **Servicios afectados**: mb-business, mb-frontend
- **APIs externas**: Stripe API v2023-10-16
```

## Estimación y Planificación

### Técnica de Estimación por Puntos

**Factores a considerar:**
- **Complejidad técnica** (1-5 puntos)
- **Tamaño del cambio** (1-5 puntos)
- **Dependencias** (0-3 puntos)
- **Riesgo técnico** (0-3 puntos)
- **Testing requerido** (1-3 puntos)

**Conversión a tiempo:**
- 1-5 puntos: XS (1-2 horas)
- 6-10 puntos: S (0.5-1 día)
- 11-15 puntos: M (2-3 días)
- 16-20 puntos: L (1 semana)
- 21+ puntos: XL (considerar dividir)

### Planificación de Sprints

1. **Priorizar por dependencias**: Tickets bloqueantes primero
2. **Balancear por servicio**: No sobrecargar un solo servicio
3. **Considerar capacidad del equipo**: No más de 80% de capacidad
4. **Incluir buffer**: 20% para imprevistos

## Testing y Calidad

### Estrategia de Testing por Tipo de Ticket

**Features de API (mb-business):**
```markdown
## Testing
- [ ] Unit tests para lógica de negocio
- [ ] Integration tests para endpoints
- [ ] Contract tests para APIs públicas
- [ ] Performance tests para endpoints críticos
- [ ] Security tests para autenticación/autorización
```

**Features de Frontend (mb-frontend):**
```markdown
## Testing
- [ ] Unit tests para componentes
- [ ] Integration tests para flujos
- [ ] E2E tests para user journeys críticos
- [ ] Visual regression tests
- [ ] Accessibility tests
```

**Features de Base de Datos (mb-db):**
```markdown
## Testing
- [ ] Migration tests (up/down)
- [ ] Data integrity tests
- [ ] Performance tests para queries
- [ ] Backup/restore tests
- [ ] Rollback tests
```

### Criterios de Calidad

**Definition of Done:**
- [ ] Código implementado y revisado
- [ ] Tests automatizados pasando
- [ ] Documentación actualizada
- [ ] Criterios de aceptación verificados
- [ ] Performance validado
- [ ] Security review completado
- [ ] Deploy en staging exitoso

## Comunicación y Colaboración

### Actualizaciones de Estado

**Frecuencia recomendada:**
- **Daily standups**: Mencionar tickets en progreso
- **Cambios de estado**: Actualizar inmediatamente
- **Blockers**: Comunicar dentro de 2 horas
- **Completado**: Actualizar el mismo día

### Formato de Comunicación

**En comentarios del ticket:**
```markdown
**[YYYY-MM-DD HH:MM] - [Nombre]**
Estado: En desarrollo → En testing
Progreso: Implementación completada, iniciando tests unitarios
Blockers: Ninguno
Next steps: Completar tests de integración
ETA: Mañana EOD
```

### Escalación

**Niveles de escalación:**
1. **Nivel 1**: Desarrollador → Tech Lead (blockers técnicos)
2. **Nivel 2**: Tech Lead → Product Owner (cambios de scope)
3. **Nivel 3**: Product Owner → Stakeholders (cambios de prioridad)

## Mantenimiento del Sistema

### Limpieza Regular

**Semanal:**
- Revisar tickets en estado "En análisis" > 1 semana
- Mover tickets completados a carpeta `tickets/completed/`
- Actualizar métricas de progreso

**Mensual:**
- Archivar tickets completados > 1 mes
- Revisar y actualizar plantillas
- Analizar métricas de estimación vs. realidad
- Actualizar guías basado en lecciones aprendidas

### Archivo de Tickets

**Estructura de archivo:**
```
tickets/completed/
├── 2025/
│   ├── 01-enero/
│   ├── 02-febrero/
│   └── ...
└── archive-index.md
```

**Contenido de archive-index.md:**
```markdown
# Índice de Tickets Archivados

## 2025

### Enero
- `20250115142030_implement_user_auth.md` - mb-business - Completado
- `20250118093045_add_payment_gateway.md` - mb-commerce-channels - Completado

### Febrero
- ...
```

## Métricas y Mejora Continua

### KPIs Recomendados

**Velocidad:**
- Lead time promedio por tipo de ticket
- Cycle time por servicio
- Throughput por sprint

**Calidad:**
- Defectos post-implementación
- Tickets reabiertos
- Tiempo de resolución de bugs

**Predictibilidad:**
- Precisión de estimaciones
- Variabilidad de cycle time
- Cumplimiento de fechas objetivo

### Retrospectivas

**Preguntas clave:**
1. ¿Qué tickets tomaron más tiempo del estimado y por qué?
2. ¿Qué dependencias no identificamos correctamente?
3. ¿Qué información faltó en los tickets?
4. ¿Cómo podemos mejorar la calidad de los criterios de aceptación?

### Mejora de Procesos

**Ciclo de mejora:**
1. **Medir**: Recopilar métricas semanalmente
2. **Analizar**: Identificar patrones y problemas
3. **Experimentar**: Probar mejoras en pequeña escala
4. **Implementar**: Adoptar mejoras exitosas
5. **Documentar**: Actualizar guías y plantillas

## Herramientas y Automatización

### Scripts Útiles

**Crear nuevo ticket:**
```bash
#!/bin/bash
# create-ticket.sh
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
TICKET_NAME="$1"
if [ -z "$TICKET_NAME" ]; then
    echo "Uso: ./create-ticket.sh nombre_del_ticket"
    exit 1
fi
cp templates/ticket-template.md "tickets/active/${TIMESTAMP}_${TICKET_NAME}.md"
echo "Ticket creado: tickets/active/${TIMESTAMP}_${TICKET_NAME}.md"
```

**Buscar tickets por estado:**
```bash
#!/bin/bash
# find-by-status.sh
STATUS="$1"
if [ -z "$STATUS" ]; then
    echo "Uso: ./find-by-status.sh 'En desarrollo'"
    exit 1
fi
grep -r "- \[x\] $STATUS" tickets/active/
```

### Integración con Git

**Hooks recomendados:**
- **pre-commit**: Validar formato de tickets
- **commit-msg**: Referenciar tickets en commits
- **post-merge**: Actualizar índices automáticamente

**Formato de commits:**
```
feat(mb-business): implement user authentication

Refs: 20250527023056_create_user_authentication_middleware.md
```

## Troubleshooting Común

### Problemas Frecuentes

**Ticket muy amplio:**
- **Síntoma**: Estimación > 2 semanas
- **Solución**: Dividir en tickets más pequeños
- **Prevención**: Revisar alcance en fase de análisis

**Dependencias circulares:**
- **Síntoma**: Tickets que se bloquean mutuamente
- **Solución**: Refactorizar para eliminar dependencia
- **Prevención**: Mapear dependencias antes de crear tickets

**Criterios de aceptación ambiguos:**
- **Síntoma**: Discusiones sobre si está "completado"
- **Solución**: Refinar criterios con ejemplos específicos
- **Prevención**: Usar formato "Dado-Cuando-Entonces"

**Estimaciones consistentemente incorrectas:**
- **Síntoma**: Tickets siempre toman más tiempo
- **Solución**: Analizar factores no considerados
- **Prevención**: Incluir buffer y revisar estimaciones históricas 