# AVD Setup for local development

## Prerequisites

- Android SDK installed at `C:\Android`
- Hardware virtualization enabled (Intel VT-x / AMD-V)
- Windows Hypervisor Platform (WHPX) or Intel HAXM

## Scripts

| Script | Purpose |
|--------|---------|
| `create_avd.ps1` | One-time setup: installs system image and creates AVD |
| `start_emulator.ps1` | Starts the emulator (use daily) |

## Quick Start

### 1. Create AVD (first time only)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File frontend/tools/create_avd.ps1
```

### 2. Start Emulator

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File frontend/tools/start_emulator.ps1
```

Or use VS Code: **Tasks > Run Task > Android: Start Emulator**

### 3. Run App

```powershell
cd frontend
flutter run -d emulator-5554
```

## Options

### create_avd.ps1

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-AvdName` | `croiz_avd` | Name of the AVD |
| `-SystemImage` | `system-images;android-30;google_apis;x86_64` | Android image |
| `-Device` | `pixel` | Device profile |

### start_emulator.ps1

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-AvdName` | `croiz_avd` | Name of the AVD to start |
| `-WipeData` | `false` | Reset emulator to clean state |
| `-TimeoutSeconds` | `60` | Max wait time for adb connection |

## Troubleshooting

- **Emulator slow?** Enable hardware acceleration (WHPX/HAXM)
- **Not connecting?** Run `adb kill-server && adb start-server`
- **Need clean slate?** Use `start_emulator.ps1 -WipeData`
