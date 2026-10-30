#!/bin/bash

MAIN_FILE="maina.py"
MODEL_NAME="gemma4:31b-cloud"
RESTART_INTERVAL=10800

if [ -n "$OLLAMA_API_KEY" ]; then
    export OLLAMA_API_KEY="$OLLAMA_API_KEY"
    echo "🔑 تم تحميل OLLAMA_API_KEY."
else
    echo "⚠️ تحذير: OLLAMA_API_KEY غير موجود في البيئة."
fi

start_ollama() {
    echo "🚀 [$(date)] تشغيل ollama serve..."
    nohup ollama serve > /tmp/ollama.log 2>&1 &
    for i in $(seq 1 30); do
        if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            echo "✅ Ollama يستجيب على المنفذ 11434."
            return 0
        fi
        sleep 2
    done
    echo "❌ Ollama لم يستجب بعد 60 ثانية."
}

pull_model() {
    echo "⬇️ [$(date)] سحب الموديل $MODEL_NAME..."
    ollama pull "$MODEL_NAME" || echo "⚠️ فشل سحب الموديل، سيُعاد المحاولة لاحقاً"
}

supervise_ollama() {
    while true; do
        if ! pgrep -f "ollama serve" > /dev/null; then
            echo "⚠️ [$(date)] ollama serve متوقفة، إعادة تشغيلها..."
            start_ollama
        fi
        sleep 60
    done
}

run_bot_loop() {
    while true; do
        echo "🤖 [$(date)] تشغيل $MAIN_FILE (مهلة $RESTART_INTERVAL ثانية)..."
        if [ ! -f "$MAIN_FILE" ]; then
            echo "❌ [$(date)] الملف $MAIN_FILE غير موجود في المجلد الحالي! تحقق من اسم الملف."
            ls -la *.py 2>/dev/null
            sleep 30
            continue
        fi
        timeout "$RESTART_INTERVAL" python3 "$MAIN_FILE"
        EXIT_CODE=$?
        echo "⚠️ [$(date)] $MAIN_FILE توقف (exit code: $EXIT_CODE)، إعادة التشغيل خلال 5 ثواني..."
        sleep 5
    done
}

start_ollama
pull_model
supervise_ollama &
run_bot_loop
