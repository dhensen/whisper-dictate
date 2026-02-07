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

### Install whisper.cpp

Pick **one** of the following `whisper.cpp` packages depending on your hardware:

| Package | GPU | When to use |
|---------|-----|-------------|
| `whisper.cpp-vulkan` | AMD/NVIDIA/Intel (Vulkan) | Recommended for most GPU-accelerated setups |
| `whisper.cpp-hip` | AMD (ROCm) | If you already have a ROCm stack configured |
| `whisper.cpp` | None (CPU only) | No compatible GPU, or just want simplicity |

These packages conflict with each other — only one can be installed at a time.

```bash
# Example: Vulkan (most common)
paru -S whisper.cpp-vulkan whisper.cpp-model-large-v3-turbo ydotool libnotify
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

> **Note:** If using the CPU-only build, remove `--flash-attn` from the script as it requires GPU support.

## Usage

Run the script to toggle dictation on/off:

```bash
whisper-dictate-toggle
```

- **First run** starts `whisper-stream` and begins typing transcribed speech at your cursor position.
- **Second run** kills the process and stops dictation.

Desktop notifications will confirm the current state.

### Bind to a hotkey

For hands-free toggling, bind the script to a keyboard shortcut in your desktop environment. For example in Hyprland:

```
bind = , F9, exec, whisper-dictate-toggle
```

## Configuration

You can tune these parameters in the script:

| Parameter      | Default          | Description                                     |
| -------------- | ---------------- | ----------------------------------------------- |
| `-t`           | `8`              | CPU threads used alongside the GPU              |
| `--step`       | `0`              | Audio step size in ms (0 = as fast as possible) |
| `--length`     | `5000`           | Audio chunk length in ms                        |
| `--flash-attn` | enabled          | Flash attention for faster GPU inference        |
| `-m`           | `large-v3-turbo` | Whisper model path                              |

## How it works

1. `whisper-stream` captures microphone audio and streams transcriptions to stdout
2. A `while read` loop filters out metadata (timestamps, markers) and extracts the speech text
3. `ydotool type` simulates keyboard input to type the transcription at your cursor
4. The process group PID is saved to `/tmp/whisper_dictate.pid` so a second invocation can cleanly kill everything

## Issues

Issues related to third-party dependencies (whisper-stream, ydotool, etc.) should be reported at their respective upstream repositories, not here. This project is only the toggling/typing wrapper around them.

## Contributing

Contributions are welcome! Please open a PR that clearly states what problem is being solved.
