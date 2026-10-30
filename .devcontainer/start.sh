#!/bin/bash

LOG_DIR="logs"
mkdir -p "$LOG_DIR"

MODEL_NAME="gemma4:31b-cloud"
RESTART_INTERVAL=10800

echo "🚀 بدء تشغيل نظام Ollama..."

if [ -n "$OLLAMA_API_KEY" ]; then
    echo "🔑 تم العثور على OLLAMA_API_KEY، جاري التصدير..."
    export OLLAMA_API_KEY="$OLLAMA_API_KEY"
else
    echo "⚠️ تحذير: OLLAMA_API_KEY غير موجود كـ Codespaces Secret."
    echo "   الموديلات من نوع Cloud (مثل gemma4:31b-cloud) لن تعمل بدونه."
fi

start_ollama() {
    nohup ollama serve > "$LOG_DIR/ollama.log" 2>&1 &
    echo "Ollama PID: $!"
    for i in $(seq 1 30); do
        if curl -s http://localhost:11434/api/tags > /dev/null; then
            echo "✅ Ollama API شغال على المنفذ 11434"
            return 0
        fi
        sleep 2
    done
    echo "❌ فشل تشغيل Ollama API بعد عدة محاولات"
    return 1
}

pull_model() {
    echo "📥 جاري سحب/التحقق من الموديل: $MODEL_NAME"
    ollama pull "$MODEL_NAME" 2>&1 | tee -a "$LOG_DIR/ollama.log"
}

supervise_ollama() {
    while true; do
        if ! pgrep -f "ollama serve" > /dev/null; then
            echo "⚠️ [$(date)] Ollama متوقف، جاري إعادة تشغيله..."
            start_ollama
        fi
        sleep 60
    done
}

run_bot_loop() {
    while true; do
        echo "🤖 [$(date)] بدء تشغيل maina.py (إعادة تشغيل تلقائي كل 3 ساعة)"
        timeout "$RESTART_INTERVAL" python3 maina.py >> "$LOG_DIR/bot.log" 2>&1
        EXIT_CODE=$?
        echo "⚠️ [$(date)] maina.py توقف (exit code: $EXIT_CODE)، إعادة التشغيل خلال 5 ثواني..."
        sleep 5
    done
}

start_ollama
pull_model
supervise_ollama &
run_bot_loop
