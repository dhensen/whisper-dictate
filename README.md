# Whisper Dictate

Local speech-to-text dictation using [whisper.cpp](https://github.com/ggerganov/whisper.cpp). Toggle it on, speak, and your words get typed wherever your cursor is.

## Install

| Distribution | Package |
|--------------|---------|
| Arch Linux (or derivative) | [`whisper-dictate-git`](https://aur.archlinux.org/packages/whisper-dictate-git) (AUR) |

```bash
paru -S whisper-dictate-git
```

## Prerequisites

- **Arch Linux** (or derivative)
- [ydotool](https://github.com/ReimuNotMoe/ydotool) for simulating keyboard input
- [libnotify](https://gitlab.gnome.org/GNOME/libnotify) for desktop notifications (`notify-send`)
- [PipeWire](https://pipewire.org/) for recording the microphone (`pw-record`)

### Install whisper.cpp

Install the official `whisper-cpp` package plus **one** `ggml` backend matching your hardware:

| Backend package | GPU | When to use |
|-----------------|-----|-------------|
| `ggml-vulkan` | AMD/NVIDIA/Intel (Vulkan) | Recommended for most GPU-accelerated setups |
| `ggml-cuda` | NVIDIA (CUDA) | If you already have a CUDA stack configured |
| `ggml-hip` | AMD (ROCm) | If you already have a ROCm stack configured |
| *(none)* | None (CPU only) | No compatible GPU, or just want simplicity |

```bash
# Example: Vulkan (most common)
sudo pacman -S whisper-cpp ggml-vulkan ydotool libnotify pipewire-audio
paru -S whisper.cpp-model-large-v3-turbo
```

### Set up ydotool

ydotool needs access to `/dev/uinput`. Create a udev rule:

```bash
sudo tee /etc/udev/rules.d/80-uinput.rules <<'EOF'
KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
EOF
```

Add your user to the `input` group:

```bash
sudo usermod -aG input $USER
```

Reboot for the group and udev changes to take effect, then enable the daemon:

```bash
systemctl --user enable --now ydotool
```

## Usage

Run the script to toggle dictation on/off:

```bash
whisper-dictate-toggle
```

- **First run** starts recording your microphone.
- **Second run** stops recording, transcribes everything you said, and types it at your cursor position.

Desktop notifications will confirm the current state.

### Recording indicator

While recording, a small bar appears at the bottom of the screen with a pulsing red dot, the elapsed time and a live frequency spectrum of your microphone, so you can see that dictation is on and your voice is being picked up. The dot turns grey if no audio arrives, and the bar shows "Transcribing…" after you stop.

The indicator uses the layer-shell protocol (KDE Plasma, Hyprland, Sway, ...) so it never takes keyboard focus away from the window you're dictating into. It needs these optional packages:

```bash
sudo pacman -S python-gobject gtk4 gtk4-layer-shell
```

Without them, or on a desktop without layer-shell support (e.g. GNOME), dictation works the same with only the notifications.

### Bind to a hotkey

For hands-free toggling, bind the script to a keyboard shortcut in your desktop environment.

**Hyprland:**

```
bind = , F9, exec, whisper-dictate-toggle
```

**KDE Plasma:**

1. Open System Settings > Keyboard > Shortcuts
2. Click **+ Add New** > **Command or Script**
3. Set the command to `/usr/bin/whisper-dictate-toggle`
4. Assign your preferred shortcut (e.g. Meta+S)

## Configuration

Set these environment variables to override the defaults:

| Variable                    | Default          | Description                                             |
| --------------------------- | ---------------- | ------------------------------------------------------- |
| `WHISPER_DICTATE_MODEL`     | `large-v3-turbo` | Whisper model path                                      |
| `WHISPER_DICTATE_LANG`      | `en`             | Spoken language (e.g. `nl`), or `auto` to detect it     |
| `WHISPER_DICTATE_THREADS`   | `8`              | CPU threads used alongside the GPU                      |
| `WHISPER_DICTATE_KEY_DELAY` | `4`              | ydotool key delay/hold in ms; raise if characters drop  |
| `WHISPER_DICTATE_PORT`      | `8178`           | Local port for the temporary `whisper-server`           |
| `WHISPER_DICTATE_VAD_MODEL` | `~/.local/share/whisper-dictate/ggml-silero-v5.1.2.bin` | Optional Silero VAD model (see below) |

### Voice activity detection (optional, recommended)

With a Silero VAD model in place, silence is skipped before transcription, which stops Whisper from hallucinating text during pauses:

```bash
mkdir -p ~/.local/share/whisper-dictate
curl -L -o ~/.local/share/whisper-dictate/ggml-silero-v5.1.2.bin \
  https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin
```

## How it works

1. `pw-record` captures microphone audio (16 kHz mono) to a temporary WAV file, while `whisper-server` loads the model onto the GPU in the background
2. On the second toggle, the recorder is stopped and the whole recording is sent to the local server for transcription in one pass, after which the server exits
3. Non-speech annotations such as `[BLANK_AUDIO]` or `(music)` are stripped
4. `ydotool type` simulates keyboard input to type the transcription at your cursor

The recorder and server run as transient systemd user units (`whisper-dictate-rec`, `whisper-dictate-server`) so they survive the hotkey launcher. Logs from the server are in `$XDG_RUNTIME_DIR/whisper-dictate/server.log`.

## Issues

Issues related to third-party dependencies (whisper.cpp, ydotool, etc.) should be reported at their respective upstream repositories, not here. This project is only the toggling/typing wrapper around them.

## Contributing

Contributions are welcome! Please open a PR that clearly states what problem is being solved.
