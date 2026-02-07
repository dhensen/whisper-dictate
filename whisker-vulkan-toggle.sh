# Configuration
MODEL="/usr/share/whisper.cpp-model-large-v3-turbo/ggml-large-v3-turbo.bin"
PID_FILE="/tmp/whisper_vulkan.pid"

if [ -f "$PID_FILE" ]; then
    # Toggle OFF: Kill the process group (the stream + while loop)
    PID=$(cat "$PID_FILE")
    kill -- -$(ps -o pgid= -p "$PID" | tr -d ' ')
    rm "$PID_FILE"
    notify-send "Dictation" "Microphone OFF" -i mic-off -t 2000
else
    # Toggle ON: Start whisper-stream
    # --flash-attn: Speeds up AMD/Vulkan inference
    # -t 4: Uses 4 CPU threads alongside the GPU
    # --step 0: Processes audio as fast as possible
    setsid whisper-stream \
        -m "$MODEL" \
        -t 8 --step 0 --length 5000 \
        --flash-attn \
        2>/dev/null | while read -r line; do
            # Only type if line is NOT empty and NOT a hallucination
            if [[ -n "$line" ]]; then
                # Clean leading/trailing whitespace and type
                CLEAN_LINE=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                ydotool type "$CLEAN_LINE "
            fi
        done &

    echo $! > "$PID_FILE"
    notify-send "Dictation" "Microphone ON (AMD Vulkan)" -i mic-on -t 2000
fi

