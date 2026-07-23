# Quickshell Config

A clean status bar and panel configuration for **Quickshell** running on **Hyprland**, featuring dual sidebars and rounded fillet corners.

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/d5c616e9-5c59-4a7f-90e0-47630ca1c0f5" />


## Quick Start

### Option A: Use default config directory (Recommended)
Place these files in `~/.config/quickshell/` so `quickshell` loads them automatically.
```bash
# Run shell globally
quickshell
```

### Option B: Run from any directory
If files are placed elsewhere, specify the path to `shell.qml`:
```bash
quickshell /path/to/shell.qml
```

### Autostart with Hyprland
Add this to `~/.config/hypr/hyprland.conf`:
```ini
exec-once = quickshell
```
*(If you are running from a custom path, use: `exec-once = quickshell /path/to/shell.qml`)*

## Theme Configuration

Styling properties (colors, fonts, etc.) are centralized in [helpers/Theme.qml](file:///home/nithin/.config/quickshell/helpers/Theme.qml). Edit this singleton to apply changes globally across all widgets.

## Dependencies

Ensure these tools are installed:
- **Fonts**: `JetBrains Mono` (for text rendering)
- **Audio**: `wireplumber` (`wpctl`), `pulseaudio` (`pactl`)
- **Brightness**: `brightnessctl` (User must be in the `video` group: `sudo usermod -aG video $USER`)
- **Bluetooth**: `bluez-utils`, `rfkill`
- **Wifi**: `networkmanager` (provides `nmcli`)

## File Structure

- `shell.qml` - Main entrypoint
- `components/` - Bar and sidebar window panels
- `widgets/` - Wifi, bluetooth, sound, brightness, memory, battery, clock, and workspace indicators
- `helpers/` - Time and Theme singletons, and module registry
