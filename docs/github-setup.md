# 🔧 Configuración de GitHub para Automatización

Esta guía te ayudará a configurar correctamente GitHub para que las automaciones funcionen perfectamente.

## ✅ **Checklist de Configuración**

### **1. Habilitar GitHub Actions**
- [ ] Ir a **Settings** → **Actions** → **General**
- [ ] En "Actions permissions" seleccionar: **"Allow all actions and reusable workflows"**
- [ ] Hacer clic en **"Save"**

### **2. Configurar Permisos del GITHUB_TOKEN**
- [ ] En **Settings** → **Actions** → **General**
- [ ] Scroll down hasta **"Workflow permissions"**
- [ ] Seleccionar: **"Read and write permissions"**
- [ ] Marcar: **"Allow GitHub Actions to create and approve pull requests"**
- [ ] Hacer clic en **"Save"**

### **3. Configurar GitHub Pages**
- [ ] Ir a **Settings** → **Pages**
- [ ] En "Source" seleccionar: **"GitHub Actions"** (NO "Deploy from a branch")
- [ ] Hacer clic en **"Save"**
- [ ] ✨ Después del primer deploy, tendrás una URL como: `https://tu-usuario.github.io/mb-tickets`

### **4. Verificar Rama Principal**
- [ ] Confirmar que tu rama principal es `main` o `master`
- [ ] Si usas una rama diferente, actualiza el workflow en `.github/workflows/update-dashboard.yml`

## 🚀 **Activar por Primera Vez**

### **Opción 1: Push de Cambios**
```bash
# Hacer cualquier cambio en tickets/ o scripts/
git add .
git commit -m "🚀 Activar automatización de GitHub Actions"
git push
```

### **Opción 2: Ejecución Manual**
- [ ] Ir a **Actions** en tu repositorio
- [ ] Seleccionar **"📊 Update Tickets Dashboard"**
- [ ] Hacer clic en **"Run workflow"**
- [ ] Seleccionar la rama y hacer clic en **"Run workflow"**

## 🔍 **Verificar que Funciona**

### **1. Verificar GitHub Actions**
- [ ] Ir a **Actions** en tu repositorio
- [ ] Deberías ver el workflow **"📊 Update Tickets Dashboard"** ejecutándose
- [ ] Los pasos deberían mostrar ✅ verde

### **2. Verificar Actualizaciones Automáticas**
- [ ] La **descripción del repositorio** debe actualizarse con métricas
- [ ] El archivo **README.md** debe tener métricas frescas
- [ ] El archivo **dashboard.html** debe regenerarse

### **3. Verificar GitHub Pages**
- [ ] Ir a **Settings** → **Pages**
- [ ] Deberías ver: **"Your site is live at https://tu-usuario.github.io/mb-tickets"**
- [ ] El enlace debe mostrar tu dashboard

## 🐛 **Solución de Problemas**

### **Error: "Permission denied"**
```bash
# Problema: Permisos insuficientes del GITHUB_TOKEN
# Solución: Configurar "Read and write permissions" (paso 2)
```

### **Error: "Pages build failed"**
```bash
# Problema: GitHub Pages no configurado correctamente
# Solución: Seleccionar "GitHub Actions" como source (paso 3)
```

### **Error: "Workflow not triggering"**
```bash
# Problema: GitHub Actions no habilitadas
# Solución: Habilitar "Allow all actions" (paso 1)
```

### **La descripción del repo no se actualiza**
```bash
# Problema: Permisos para modificar repositorio
# Solución: Verificar "Read and write permissions" (paso 2)
```

## 📊 **Qué Esperar Después de la Configuración**

### **Automatización Diaria**
- ⏰ **8:00 AM UTC** (lunes a viernes): Actualización automática
- 📊 **Métricas**: README y descripción del repo actualizados
- 🌐 **GitHub Pages**: Dashboard accesible públicamente

### **Automatización por Cambios**
- 📝 **Cualquier commit** en `tickets/` o `scripts/`: Trigger automático
- 🔄 **1-2 minutos**: Tiempo típico de ejecución
- ✅ **Auto-commit**: Cambios automáticos en dashboard y README

### **Acceso Empresarial**
- 🔗 **URL Pública**: `https://tu-usuario.github.io/mb-tickets`
- 📱 **Responsive**: Accesible desde cualquier dispositivo
- 🕒 **24/7**: Disponible siempre, métricas actualizadas

## 🎯 **URL Final para PM/Stakeholders**

Una vez configurado, comparte esta URL con tu PM:
```
https://tu-usuario.github.io/mb-tickets
```

Esta URL mostrará automáticamente:
- 📊 Dashboard con métricas en tiempo real
- 📈 Estado de todos los tickets
- 🔄 Actualizaciones automáticas diarias
- 📱 Acceso desde cualquier dispositivo

---

💡 **Tip**: Después de la primera configuración, todo será automático. Solo necesitas hacer estos pasos una vez. 