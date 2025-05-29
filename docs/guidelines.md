# Guías del Sistema de Tickets

## Principios Fundamentales

### 1. Granularidad Apropiada
- **Un ticket = Un servicio**: Cada ticket debe enfocarse en un solo servicio
- **Funcionalidad cohesiva**: El ticket debe representar una unidad de trabajo completa y coherente
- **Independencia**: Debe poder implementarse de forma independiente (considerando dependencias)

### 2. Trazabilidad
- **Historial completo**: Documentar todas las decisiones y cambios
- **Referencias cruzadas**: Vincular tickets relacionados
- **Versionado**: Mantener historial de cambios en el ticket

### 3. Claridad y Precisión
- **Lenguaje claro**: Evitar ambigüedades
- **Criterios medibles**: Los criterios de aceptación deben ser verificables
- **Contexto suficiente**: Incluir toda la información necesaria para implementar

## Guías de Escritura

### Títulos de Tickets
**Formato recomendado**: `[VERBO]_[OBJETO]_[CONTEXTO]`

**Ejemplos buenos:**
- `create_user_authentication_middleware`
- `implement_payment_gateway_integration`
- `add_customer_notification_system`
- `update_order_status_workflow`

**Ejemplos a evitar:**
- `fix_bug` (muy genérico)
- `new_feature` (no descriptivo)
- `update_system` (muy amplio)

### Descripción del Feature
1. **Qué**: Describir claramente qué se va a implementar
2. **Por qué**: Explicar la razón de negocio
3. **Cómo**: Dar una visión general del enfoque técnico
4. **Impacto**: Mencionar el impacto esperado

### Criterios de Aceptación
- Usar formato "Dado... Cuando... Entonces..."
- Ser específicos y medibles
- Incluir casos edge
- Considerar escenarios de error

**Ejemplo:**
```
- [ ] Dado que un usuario está autenticado, cuando accede al endpoint /api/orders, entonces debe recibir solo sus órdenes
- [ ] Dado que un usuario no está autenticado, cuando accede al endpoint /api/orders, entonces debe recibir un error 401
- [ ] Dado que un usuario tiene más de 100 órdenes, cuando accede al endpoint /api/orders, entonces debe recibir paginación
```

## Gestión de Estados

### Flujo de Estados
```
En análisis → En desarrollo → En testing → En revisión → En staging → Completado
     ↓              ↓             ↓            ↓           ↓
  Cancelado    Cancelado    Cancelado    Cancelado   Cancelado
```

### Criterios para Cambio de Estado

**En análisis → En desarrollo:**
- Todos los requisitos están claros
- Dependencias identificadas
- Estimación realizada
- Desarrollador asignado

**En desarrollo → En testing:**
- Código implementado
- Unit tests pasando
- Code review inicial completado

**En testing → En revisión:**
- Todos los tests pasando
- Criterios de aceptación verificados
- Documentación actualizada

**En revisión → En staging:**
- Code review aprobado
- Tests de integración pasando
- Aprobación del product owner

**En staging → Completado:**
- Tests en staging exitosos
- Aprobación final
- Deploy a producción exitoso

## Gestión de Dependencias

### Tipos de Dependencias
1. **Dependencias de datos**: Cambios en esquemas de BD
2. **Dependencias de API**: Cambios en contratos de API
3. **Dependencias de infraestructura**: Cambios en configuración
4. **Dependencias de negocio**: Orden de implementación por lógica de negocio

### Documentación de Dependencias
```markdown
## Dependencias
- **Tickets bloqueantes**: [lista de tickets que deben completarse antes]
- **Tickets dependientes**: [lista de tickets que dependen de este]
- **Servicios afectados**: [servicios que pueden verse impactados]
- **APIs externas**: [servicios externos que se integran]
```

## Estimación

### Criterios de Estimación
- **Complejidad técnica**: Dificultad de implementación
- **Tamaño del cambio**: Líneas de código estimadas
- **Dependencias**: Tiempo de coordinación
- **Testing**: Tiempo de pruebas
- **Documentación**: Tiempo de documentación

### Escalas Recomendadas
- **XS**: 1-2 horas (cambios menores)
- **S**: 0.5-1 día (features simples)
- **M**: 2-3 días (features medianos)
- **L**: 1 semana (features complejos)
- **XL**: 2+ semanas (features muy complejos, considerar dividir)

## Mejores Prácticas por Servicio

### mb-business (Lógica de Negocio)
- Enfocarse en reglas de negocio
- Documentar casos edge de negocio
- Considerar impacto en otros servicios
- Validar con stakeholders de negocio

### mb-commerce-channels (Canales de Comercio)
- Considerar diferentes tipos de canal
- Documentar configuraciones por canal
- Validar integraciones externas
- Considerar escalabilidad

### mb-frontend (Frontend)
- Incluir mockups o wireframes
- Considerar responsive design
- Documentar interacciones UX
- Validar accesibilidad

### mb-cloud-automation (Infraestructura)
- Documentar cambios de configuración
- Considerar impacto en otros servicios
- Incluir rollback procedures
- Validar en múltiples ambientes

### mb-db (Base de Datos)
- Incluir scripts de migración
- Documentar impacto en performance
- Considerar backup/restore
- Validar integridad referencial

### mb-agents (Agentes)
- Documentar comportamiento de agentes
- Considerar concurrencia
- Incluir métricas de performance
- Validar manejo de errores

## Revisión y Aprobación

### Checklist de Revisión
- [ ] Título descriptivo y claro
- [ ] Descripción completa y precisa
- [ ] Criterios de aceptación específicos
- [ ] Dependencias identificadas
- [ ] Estimación realista
- [ ] Consideraciones técnicas documentadas
- [ ] Plan de testing definido
- [ ] Documentación requerida identificada

### Roles en la Revisión
- **Tech Lead**: Revisión técnica y arquitectural
- **Product Owner**: Validación de requisitos de negocio
- **QA**: Validación de criterios de testing
- **DevOps**: Validación de impacto en infraestructura

## Métricas y Seguimiento

### Métricas Recomendadas
- **Lead time**: Tiempo desde creación hasta completado
- **Cycle time**: Tiempo desde inicio de desarrollo hasta completado
- **Throughput**: Tickets completados por sprint/mes
- **Quality**: Defectos encontrados post-implementación

### Reportes Sugeridos
- Dashboard de estado de tickets activos
- Reporte de dependencias bloqueantes
- Análisis de estimación vs. tiempo real
- Reporte de tickets por servicio 