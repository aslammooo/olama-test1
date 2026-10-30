#!/bin/bash
set -e

echo "🔧 جاري تثبيت Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

echo "🔧 جاري تثبيت متطلبات بايثون..."
if [ -f requirements.txt ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
fi

chmod +x .devcontainer/start.sh || true

echo "✅ تم الإعداد بنجاح"
