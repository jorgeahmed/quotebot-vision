#!/bin/bash
set -e

# QuoteBot - Script de Configuración de Firebase
# Este script requiere interacción del usuario

echo "🔥 Configuración de Firebase para QuoteBot"
echo "=========================================="
echo ""

# Agregar flutterfire al PATH para esta sesión
export PATH="$PATH:$HOME/.pub-cache/bin"

# Paso 1: Login a Firebase
echo "📝 Paso 1/3: Autenticación con Firebase"
echo "Se abrirá el navegador para autenticarse..."
echo ""
firebase login

# Paso 2: Configurar FlutterFire
echo ""
echo "⚙️  Paso 2/3: Configurando FlutterFire"
echo "Proyecto GCP: quotebot-vision-hackathon"
echo ""
cd app
flutterfire configure --project=quotebot-vision-hackathon

# Paso 3: Verificar archivos generados
echo ""
echo "✅ Paso 3/3: Verificando archivos generados"
echo ""

if [ -f "lib/firebase_options.dart" ]; then
    echo "✓ firebase_options.dart creado"
else
    echo "✗ firebase_options.dart NO encontrado"
fi

if [ -f "android/app/google-services.json" ]; then
    echo "✓ google-services.json creado"
else
    echo "✗ google-services.json NO encontrado"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✓ GoogleService-Info.plist creado"
else
    echo "⚠ GoogleService-Info.plist NO encontrado (OK si solo usas Android)"
fi

echo ""
echo "🎉 Configuración completada!"
echo ""
echo "Próximos pasos:"
echo "1. Verificar que Firebase esté configurado en la app"
echo "2. Habilitar Firestore y Storage en Firebase Console"
echo "3. Actualizar main.dart para inicializar Firebase"
