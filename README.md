# QuoteBot Vision

Aplicación Flutter para generar cotizaciones de construcción automáticamente usando IA (Google Gemini).

## 🚀 Características

- 📹 Grabación de video de espacios de construcción
- 🤖 Análisis automático con IA (Google Gemini)
- 💰 Generación de cotizaciones detalladas
- 📊 Gestión de proyectos y trabajos
- 💬 Chat integrado para comunicación
- 💳 Sistema de pagos

## 🏗️ Tecnologías

- **Frontend:** Flutter 3.19.0
- **Backend:** Hono.js en Google Cloud Run
- **Base de datos:** Firebase Firestore
- **Storage:** Google Cloud Storage
- **IA:** Google Vertex AI (Gemini)

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Web
- ✅ Linux
- ✅ Windows

## 🎨 Branding

**Powered by Mantenimiento Sinai**

La aplicación incluye branding de Mantenimiento Sinai en:
- Dashboard (header y footer)
- Página de cotización (footer compacto)
- Icono de la aplicación

## 🔧 Desarrollo

### Requisitos

- Flutter 3.19.0 o superior
- Dart 3.3.0 o superior
- Android SDK (para Android)
- Xcode (para iOS/macOS)

### Instalación

```bash
cd app
flutter pub get
flutter run
```

### Build para Producción

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ipa --release
```

**Web:**
```bash
flutter build web --release
```

## 🚀 CI/CD

El proyecto usa GitHub Actions para builds automáticos.

Ver: [Guía de GitHub Actions](docs/github_actions_guide.md)

## 📄 Licencia

Propiedad de Mantenimiento Sinai

## 📞 Contacto

**Desarrollado para:** Mantenimiento Sinai  
**Versión:** 1.0.0
