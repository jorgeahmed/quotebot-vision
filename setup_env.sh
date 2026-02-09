#!/bin/bash

echo "🔧 Configurando entorno..."

# 1. Detectar NVM (puede estar en .config/nvm en Debian)
export NVM_DIR="$HOME/.nvm"
[ -d "$HOME/.config/nvm" ] && export NVM_DIR="$HOME/.config/nvm"

# 2. Cargar NVM si ya existe, o instalarlo
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
else
  echo "📦 Instalando NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  # Re-detectar y cargar
  [ -d "$HOME/.config/nvm" ] && export NVM_DIR="$HOME/.config/nvm"
  \. "$NVM_DIR/nvm.sh"
fi

# 3. Instalar Node
if ! command -v node &> /dev/null; then
  echo "📦 Instalando Node.js LTS..."
  nvm install --lts
else
  echo "✅ Node.js ya está instalado."
fi

# 4. Ir a la carpeta correcta e instalar dependencias
if [ -d "qoutebot" ]; then
  cd qoutebot
  echo "📂 Entrando a carpeta qoutebot..."
elif [ -f "package.json" ] && grep -q "quotebot-frontend" "package.json"; then
  echo "📂 Ya estás en la carpeta del frontend."
else
  echo "⚠️ No encuentro la carpeta 'qoutebot'. Ejecutando npm install donde estamos..."
fi

echo "📦 Instalando dependencias con NPM..."
npm install

echo ""
echo "🎉 ¡INSTALACIÓN TERMINADA!"
echo "==============================================="
echo "🔴 IMPORTANTE: Tu terminal no sabe que instalaste Node aún."
echo "🟢 EJECUTA ESTOS COMANDOS MANUALMENTE AHORA:"
echo ""
echo "source ~/.bashrc"
echo "npm start"
echo "==============================================="
