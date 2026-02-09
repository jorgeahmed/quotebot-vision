# Backend QuoteBot - Información de Deployment

## 🌐 URL del Servicio

**Production URL:** https://quotebot-backend-421764703984.us-central1.run.app

## 📋 Endpoints Disponibles

### 1. Health Check
```bash
GET /
```
**Respuesta:** `QuoteBot Vision Backend Online`

**Ejemplo:**
```bash
curl https://quotebot-backend-421764703984.us-central1.run.app/
```

---

### 2. Obtener URL de Upload
```bash
GET /upload-url?filename={FILENAME}&contentType={CONTENT_TYPE}
```

**Parámetros:**
- `filename` (requerido): Nombre del archivo a subir
- `contentType` (opcional): Tipo MIME, default: `video/mp4`

**Respuesta:**
```json
{
  "uploadUrl": "https://storage.googleapis.com/...",
  "gcsUri": "gs://quotebot-vision-hackathon_videos/..."
}
```

**Ejemplo:**
```bash
curl "https://quotebot-backend-421764703984.us-central1.run.app/upload-url?filename=mi-video.mp4"
```

---

### 3. Analizar Video
```bash
POST /analyze
Content-Type: application/json
```

**Body:**
```json
{
  "projectId": "project_123",
  "videoGcsUri": "gs://quotebot-vision-hackathon_videos/video.mp4"
}
```

**Respuesta:**
```json
{
  "success": true,
  "jobId": "job_1735368735123",
  "message": "Analysis completed"
}
```

**Ejemplo:**
```bash
curl -X POST https://quotebot-backend-421764703984.us-central1.run.app/analyze \
  -H "Content-Type: application/json" \
  -d '{"projectId":"test","videoGcsUri":"gs://bucket/video.mp4"}'
```

---

### 4. Consultar Estado de Job
```bash
GET /jobs/{JOB_ID}
```

**Respuesta:**
```json
{
  "id": "job_1735368735123",
  "projectId": "project_123",
  "videoUri": "gs://...",
  "status": "completed",
  "createdAt": "2025-12-28T...",
  "completedAt": "2025-12-28T...",
  "analysis": {
    "dimensions": "...",
    "materials": [...],
    "difficulty": 5,
    "summary": "..."
  }
}
```

**Ejemplo:**
```bash
curl https://quotebot-backend-421764703984.us-central1.run.app/jobs/job_1735368735123
```

---

### 5. Crear Proyecto
```bash
POST /projects
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Proyecto Casa Nueva",
  "address": "Calle Principal 123",
  "description": "Renovación completa"
}
```

**Respuesta:**
```json
{
  "id": "abc123xyz",
  "success": true
}
```

---

## 🔧 Configuración

### Variables de Entorno
- `GOOGLE_CLOUD_PROJECT`: `quotebot-vision-hackathon`
- `PORT`: `8080` (configurado por Cloud Run)

### Región
- `us-central1`

### Permisos IAM Configurados
- `roles/storage.admin` - Para crear buckets y URLs firmadas
- `roles/iam.serviceAccountTokenCreator` - Para auto-firmarse
- `roles/editor` - Acceso general al proyecto

---

## 📦 Detalles Técnicos

### Container
- **Imagen:** `gcr.io/quotebot-vision-hackathon/quotebot-backend:latest`
- **Base:** Node.js 20 slim
- **Revision:** `quotebot-backend-00004-4cf`

### Servicio Cloud Run
- **Nombre:** `quotebot-backend`
- **Región:** `us-central1`
- **Acceso:** Público (sin autenticación)
- **Traffic:** 100% en última revisión

---

## 🔗 Integración con Flutter

### Configurar en Flutter App

```dart
// lib/core/constants.dart
class ApiConstants {
  static const String baseUrl = 'https://quotebot-backend-421764703984.us-central1.run.app';
  
  static String get uploadUrl => '$baseUrl/upload-url';
  static String get analyze => '$baseUrl/analyze';
  static String jobs(String jobId) => '$baseUrl/jobs/$jobId';
  static String get projects => '$baseUrl/projects';
}
```

### Ejemplo de Uso

```dart
import 'package:dio/dio.dart';

final dio = Dio();

// 1. Obtener URL de upload
final response = await dio.get(
  ApiConstants.uploadUrl,
  queryParameters: {'filename': 'video_${DateTime.now().millisecondsSinceEpoch}.mp4'},
);

final uploadUrl = response.data['uploadUrl'];
final gcsUri = response.data['gcsUri'];

// 2. Subir video
await dio.put(
  uploadUrl,
  data: videoBytes,
  options: Options(
    headers: {'Content-Type': 'video/mp4'},
  ),
);

// 3. Trigger análisis
final analyzeResponse = await dio.post(
  ApiConstants.analyze,
  data: {
    'projectId': projectId,
    'videoGcsUri': gcsUri,
  },
);

final jobId = analyzeResponse.data['jobId'];

// 4. Polling para resultados
while (true) {
  final jobResponse = await dio.get(ApiConstants.jobs(jobId));
  if (jobResponse.data['status'] == 'completed') {
    final analysis = jobResponse.data['analysis'];
    break;
  }
  await Future.delayed(Duration(seconds: 5));
}
```

---

## 🔍 Logs y Monitoreo

**Ver logs en tiempo real:**
```bash
gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=quotebot-backend" --limit=50
```

**Cloud Console Logs:**
https://console.cloud.google.com/run/detail/us-central1/quotebot-backend/logs?project=quotebot-vision-hackathon

**Métricas:**
https://console.cloud.google.com/run/detail/us-central1/quotebot-backend/metrics?project=quotebot-vision-hackathon

---

## 🚀 Actualizar Deployment

Para actualizar el backend después de cambios en el código:

```bash
cd /home/ventas/quotebot-final/backend
./deploy.sh
```

Esto reconstruirá y redesplegar automáticamente.

---

## ⚠️ Notas Importantes

1. **Firestore requerido**: Para que `/analyze` y `/projects` funcionen, debes habilitar Firestore Database en Firebase Console.

2. **Límites de tiempo**: Cloud Run tiene un timeout de 60 minutos para HTTP requests. Para videos muy largos, considera usar Cloud Tasks para procesamiento asíncrono.

3. **Costos**: Monitorea el uso de Vertex AI (Gemini Vision) ya que es el componente más costoso.

4. **Storage**: El bucket `quotebot-vision-hackathon_videos` se crea automáticamente la primera vez que se solicita una URL de upload.

---

Última actualización: 2025-12-28 00:52
