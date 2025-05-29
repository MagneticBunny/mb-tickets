---
id: "20250529020058"
service: "mb-business"
priority: "Alta"
estimation: "M"
assignee: "[Por asignar]"
created: "2025-05-29"
target_date: "2025-06-05"
status: "En análisis"
tags: ["restricciones", "canal", "validacion", "cache"]
dependencies: ["20250528141230"]
related_tickets: ["20250530093045"]
external_apis: []
---

# Crear Sistema de Restricciones por Canal de Cliente

## Información General
- **Servicio afectado**: mb-business
- **Prioridad**: Alta
- **Estimación**: M (2-3 días)
- **Asignado a**: [Por asignar]
- **Fecha de creación**: 2025-05-29
- **Fecha objetivo**: 2025-06-05

## Descripción
Implementar un sistema que permita configurar restricciones específicas por canal de comercio para cada cliente. Esto incluye límites de transacciones, productos permitidos, horarios de operación y métodos de pago disponibles por canal.

## Contexto de Negocio
Los clientes empresariales necesitan diferentes configuraciones según el canal por el que operan (web, móvil, API, punto de venta). Actualmente todas las restricciones son globales, lo que limita la flexibilidad comercial y genera pérdida de ventas en algunos canales específicos.

## Requisitos Funcionales
- [ ] Crear modelo de datos para restricciones por canal
- [ ] Implementar API para gestionar restricciones por cliente y canal
- [ ] Validar restricciones en tiempo real durante transacciones
- [ ] Permitir herencia de restricciones desde configuración global
- [ ] Soportar múltiples tipos de restricciones (transaccionales, productos, horarios, pagos)

## Requisitos Técnicos
- [ ] Diseño de esquema de base de datos optimizado para consultas frecuentes
- [ ] Cache de restricciones para mejorar performance
- [ ] API RESTful con versionado
- [ ] Validación de entrada robusta
- [ ] Logging detallado para auditoría

## Dependencias
- **Servicios relacionados**: mb-commerce-channels, mb-db
- **Tickets relacionados**: 
  - `20250528141230_update_channel_configuration_schema.md` (mb-db) - Bloqueante
  - `20250530093045_frontend_channel_restrictions_ui.md` (mb-frontend) - Dependiente
- **APIs externas**: N/A
- **Librerías/Dependencias nuevas**: Redis para caching

## Criterios de Aceptación
- [ ] Dado que un administrador configura restricciones para un cliente en canal web, cuando se guarda la configuración, entonces debe persistir correctamente en la base de datos
- [ ] Dado que un cliente intenta realizar una transacción, cuando excede los límites configurados para su canal, entonces debe recibir un error específico con código 403
- [ ] Dado que no existen restricciones específicas para un canal, cuando se evalúan restricciones, entonces debe aplicar las restricciones globales del cliente
- [ ] Dado que se consultan restricciones frecuentemente, cuando se accede a la información, entonces debe responder en menos de 100ms (desde cache)
- [ ] Dado que se modifican restricciones, cuando se actualiza la configuración, entonces debe invalidar el cache automáticamente

## Consideraciones de Implementación

### Base de Datos
- Nueva tabla `customer_channel_restrictions` con índices optimizados
- Relación con tablas existentes `customers` y `channels`
- Campos JSON para configuraciones flexibles
- Migración para datos existentes

### APIs
- `GET /api/v1/customers/{id}/channels/{channel}/restrictions` - Obtener restricciones
- `PUT /api/v1/customers/{id}/channels/{channel}/restrictions` - Actualizar restricciones
- `DELETE /api/v1/customers/{id}/channels/{channel}/restrictions` - Eliminar restricciones
- `POST /api/v1/restrictions/validate` - Validar transacción contra restricciones

### Seguridad
- Autenticación requerida para todas las operaciones
- Autorización basada en roles (solo admins pueden modificar)
- Validación de entrada para prevenir inyección
- Rate limiting en endpoints de validación

### Performance
- Cache Redis con TTL de 1 hora
- Índices de base de datos en customer_id + channel_id
- Lazy loading de restricciones no utilizadas
- Batch processing para validaciones múltiples

### Monitoreo
- Métricas de latencia de validación
- Contadores de cache hit/miss
- Alertas por errores de validación
- Dashboard de uso por canal

## Testing
- [ ] Unit tests para lógica de validación de restricciones
- [ ] Integration tests para APIs de gestión
- [ ] E2E tests para flujo completo de configuración y validación
- [ ] Performance tests para validación bajo carga
- [ ] Security tests para autorización y validación de entrada

## Documentación
- [ ] Actualizar documentación de API con nuevos endpoints
- [ ] Crear guía de configuración de restricciones
- [ ] Actualizar diagramas de arquitectura del servicio
- [ ] Documentar estructura de cache y estrategias de invalidación

## Rollback Plan
1. Desactivar validación de restricciones mediante feature flag
2. Revertir cambios de API si es necesario
3. Rollback de migración de base de datos si hay problemas
4. Limpiar cache Redis de restricciones

## Notas de Implementación
- Considerar usar patrón Strategy para diferentes tipos de restricciones
- Implementar circuit breaker para llamadas a cache
- Evaluar uso de eventos para sincronización entre servicios
- Posible futura extensión para restricciones dinámicas basadas en ML

## Estado
- [x] En análisis
- [ ] En desarrollo
- [ ] En testing
- [ ] En revisión
- [ ] En staging
- [ ] Completado
- [ ] Cancelado

## Log de Cambios
| Fecha | Autor | Cambio |
|-------|-------|--------|
| 2025-05-29 | Sistema | Creación del ticket | 