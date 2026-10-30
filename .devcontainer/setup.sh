#!/bin/bash
set -e
echo "🔧 بدء تثبيت المتطلبات..."

echo "📦 تثبيت Ollama..."
curl -fsSL https://ollama.com/install.sh | sh || echo "⚠️ فشل تثبيت Ollama - سيُعاد المحاولة لاحقاً"

if [ -f "requirements.txt" ]; then
    echo "📦 تثبيت مكتبات بايثون من requirements.txt..."
    pip install --no-cache-dir -r "requirements.txt" || echo "⚠️ فشل بعض المكتبات"
fi

chmod +x .devcontainer/start.sh || true
echo "✅ انتهى الإعداد الأساسي."
