# Whisper Local Speech

Local speech-to-text dictation using [whisper.cpp](https://github.com/ggerganov/whisper.cpp) with Vulkan GPU acceleration. Toggle it on, speak, and your words get typed wherever your cursor is.

## Prerequisites

- **Arch Linux** (or derivative) with an AMD GPU supporting Vulkan
- [ydotool](https://github.com/ReimuNotMoe/ydotool) for simulating keyboard input
- [libnotify](https://gitlab.gnome.org/GNOME/libnotify) for desktop notifications (`notify-send`)

### Install dependencies

```bash
paru -S whisper.cpp-vulkan whisper.cpp-model-large-v3-turbo ydotool libnotify
```

Make sure the `ydotoold` daemon is running:

```bash
systemctl --user enable --now ydotool
```

## Usage

Run the script to toggle dictation on/off:

```bash
bash whisper-vulkan-toggle.sh
```

- **First run** starts `whisper-stream` and begins typing transcribed speech at your cursor position.
- **Second run** kills the process and stops dictation.

Desktop notifications will confirm the current state.

### Bind to a hotkey

For hands-free toggling, bind the script to a keyboard shortcut in your desktop environment. For example in Hyprland:

```
bind = , F9, exec, bash /path/to/whisper-vulkan-toggle.sh
```

## Configuration

You can tune these parameters in the script:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-t` | `8` | CPU threads used alongside the GPU |
| `--step` | `0` | Audio step size in ms (0 = as fast as possible) |
| `--length` | `5000` | Audio chunk length in ms |
| `--flash-attn` | enabled | Flash attention for faster Vulkan inference |
| `-m` | `large-v3-turbo` | Whisper model path |

## How it works

1. `whisper-stream` captures microphone audio and streams transcriptions to stdout
2. A `while read` loop filters out metadata (timestamps, markers) and extracts the speech text
3. `ydotool type` simulates keyboard input to type the transcription at your cursor
4. The process group PID is saved to `/tmp/whisper_vulkan.pid` so a second invocation can cleanly kill everything
