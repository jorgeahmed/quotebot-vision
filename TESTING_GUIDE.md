# 🧪 Guía de Testing - QuoteBot Vision App

## Pre-requisitos

Antes de probar la app, asegúrate de que:

- [x] Backend desplegado en Cloud Run ✅
- [x] Firebase configurado en Flutter ✅
- [x] URL del backend configurada en ApiConstants ✅
- [ ] **Firestore Database habilitado** ⚠️ REQUERIDO

---

## 🚀 Opción 1: Ejecutar en Dispositivo Android

### 1. Conectar dispositivo

```bash
# Verificar que el dispositivo esté conectado
adb devices
```

Debería mostrar:
```
List of devices attached
XXXXXXXX    device
```

### 2. Ejecutar app

```bash
cd /home/ventas/quotebot-final/app
flutter run
```

### 3. Probar flujo completo

1. **Dashboard:** Crea o selecciona un proyecto
2. **Camera:** Click en botón de cámara
3. **Grabar:** Graba un video corto (~5-10 segundos) de una habitación
4. **Analizar:** Click en botón "Analizar"
5. **Esperar:** Observa el progreso:
   - "Subiendo video..."
   - "Iniciando análisis..."
   - "Analizando con IA..." (puede tomar 30-60 segundos)
6. **Resultados:** Verás el análisis con materiales, dimensiones, etc.

---

## 🌐 Opción 2: Ejecutar en Chrome (Web)

Útil para debugging rápido sin hardware:

```bash
cd /home/ventas/quotebot-final/app
flutter run -d chrome
```

**Nota:** La cámara funcionará en Chrome si das permisos de acceso.

---

## 📱 Opción 3: Ejecutar en Emulador Android

### Iniciar emulador

```bash
# Listar emuladores disponibles
flutter emulators

# Iniciar emulador (reemplaza con el nombre de tu emulador)
flutter emulators --launch <emulator_id>

# O usa Android Studio para iniciar el emulador
```

### Ejecutar app

```bash
flutter run
```

---

## 🔍 Monitoreo y Debugging

### Ver logs en tiempo real (Flutter)

Los logs de Flutter se mostrarán automáticamente al ejecutar `flutter run`:

```
I/flutter: Uploading video: /storage/emulated/0/...
I/flutter: Got GCS URI: gs://quotebot-vision-hackathon_videos/...
I/flutter: Analysis started, job ID: job_...
I/flutter: Polling job status...
I/flutter: Job status: processing
I/flutter: Job status: completed
I/flutter: Analysis result: {...}
```

### Ver logs del backend (Cloud Run)

En otra terminal:

```bash
gcloud logging tail "resource.labels.service_name=quotebot-backend" \
  --project=quotebot-vision-hackathon \
  --limit=50
```

### Monitorear Cloud Run

Ver requests en tiempo real:
```
https://console.cloud.google.com/run/detail/us-central1/quotebot-backend/logs?project=quotebot-vision-hackathon
```

### Ver Firestore

Ver jobs creados:
```
https://console.firebase.google.com/project/quotebot-vision-hackathon/firestore/data
```

---

## 🧪 Casos de Prueba

### Prueba 1: Happy Path ✅

**Objetivo:** Verificar flujo completo funciona

**Pasos:**
1. Grabar video de 5-10 segundos
2. Analizar
3. Esperar resultados

**Resultado esperado:**
- ✅ Video se sube correctamente
- ✅ Análisis completa en ~30-60 segundos
- ✅ Resultados incluyen: dimensions, materials, difficulty, summary

---

### Prueba 2: Manejo de Errores 🔴

**Objetivo:** Verificar que la app maneja errores gracefully

**Escenarios:**

#### Sin conexión a internet

1. Desactivar WiFi/datos
2. Intentar analizar video

**Resultado esperado:**
- ✅ Mensaje de error descriptivo
- ✅ App no crashea

#### Video muy grande

1. Grabar video de 2-3 minutos
2. Intentar subir

**Resultado esperado:**
- ✅ Upload funciona (puede tardar más)
- ✅ O mensaje de error si excede límite

#### Firestore no habilitado

1. Analizar video sin habilitar Firestore

**Resultado esperado:**
- ❌ Error en el backend al intentar crear job
- ✅ App muestra mensaje de error

---

### Prueba 3: Performance ⚡

**Objetivo:** Verificar tiempos de respuesta

**Métricas esperadas:**
- Upload de video (10MB): ~10-30 segundos
- Análisis con Gemini: ~30-60 segundos
- Polling response time: <1 segundo
- Total end-to-end: ~60-90 segundos

---

## 🐛 Troubleshooting

### Error: "Failed to get upload URL"

**Causa:** Backend no accesible o permisos incorrectos

**Solución:**
```bash
# Verificar que el backend esté corriendo
curl https://quotebot-backend-421764703984.us-central1.run.app/
```

Debería retornar: `QuoteBot Vision Backend Online`

---

### Error: "Failed to start analysis"

**Causa:** Firestore no está habilitado

**Solución:**
1. Habilitar Firestore (ver guía)
2. Intentar de nuevo

---

### Error: "Polling timeout"

**Causa:** Análisis tomó más de lo esperado

**Solución:**
- Aumentar `maxPollingAttempts` en `ApiConstants`
- Ver logs del backend para verificar que Gemini esté funcionando

---

### App crashea al abrir cámara

**Causa:** Permisos de cámara no otorgados

**Solución:**
- En Android: Settings → Apps → QuoteBot → Permissions → Camera → Allow
- Reiniciar app

---

### Video no se sube

**Causa:** Permisos de Storage incorrectos

**Solución:**
```bash
# Verificar permisos del servicio Cloud Run
gcloud projects get-iam-policy quotebot-vision-hackathon | grep storage
```

Debería incluir `roles/storage.admin`

---

## 📊 Testing Checklist

Antes de considerar la app "completa", verificar:

- [ ] App inicia sin errores
- [ ] Firebase se inicializa correctamente
- [ ] Dashboard muestra proyectos
- [ ] Cámara abre y graba video
- [ ] Video se sube a GCS
- [ ] Análisis se dispara correctamente
- [ ] Polling funciona (actualiza estado)
- [ ] Resultados se muestran en UI
- [ ] Manejo de errores funciona
- [ ] Performance es aceptable

---

## 🎯 Siguiente Nivel

Una vez que el flujo básico funcione:

### Mejoras de UX

1. **Progress bar** durante upload
2. **Animaciones** de loading
3. **Notificaciones** cuando análisis completa
4. **Cache** de resultados anteriores

### Mejoras Técnicas

1. **Compresión de video** antes de subir
2. **Retry logic** con exponential backoff
3. **Cancelación** de uploads en progreso
4. **Thumbnails** de videos

### Producción

1. **Reglas de Firestore** más restrictivas
2. **Autenticación** de usuarios
3. **Analytics** (Firebase Analytics)
4. **Crash reporting** (Crashlytics)
5. **App signing** para release

---

## 🔗 Comandos Rápidos

```bash
# Ejecutar app
flutter run

# Hot reload (mientras app está corriendo)
# Presiona 'r' en la terminal

# Hot restart
# Presiona 'R' en la terminal

# Abrir DevTools
# Presiona 'd' en la terminal

# Ver logs del backend
gcloud logging tail "resource.labels.service_name=quotebot-backend" --limit=20

# Verificar Firestore
gcloud firestore databases list --project=quotebot-vision-hackathon
```

---

**¡Listo para probar!** 🚀

Una vez que Firestore esté habilitado, ejecuta `flutter run` y comienza a grabar videos.
