# Croiz - French Crossword Game

[![CI](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml/badge.svg)](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml)

A modern mobile crossword game built with Flutter and Spring Boot, featuring real-time gameplay, user authentication, and comprehensive scoring systems.

## Project Structure

```
croiz/
├── frontend/          # Flutter mobile application (Riverpod state management)
├── backend/           # Spring Boot REST API
├── shared/            # Shared models and constants
├── .github/workflows/ # CI/CD pipelines
└── docs/              # Project documentation
```

## Tech Stack

### Frontend
- **Framework**: Flutter 3.38+
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Local Storage**: Sqflite + flutter_secure_storage
- **Testing**: flutter_test, mockito, golden_toolkit

### Backend
- **Framework**: Spring Boot 4.0+
- **Database**: PostgreSQL
- **Security**: Spring Security + JWT
- **Build Tool**: Gradle/Maven
- **Testing**: JUnit 5, MockMvc, H2 (in-memory)


## Recent Changes (2025-11-29)

- **CI Workflow (fixed):** Updated `.github/workflows/integration-tests.yml` to remove an invalid `--target` flag previously passed to `flutter test`. The workflow now runs the test file directly: `flutter test integration_test/app_test.dart`. This prevents the `Could not find an option named "--target"` error seen in CI runs.
- **Integration Tests (TI):** Added local instructions to run integration tests. Integration tests require a connected device or an Android emulator; running `flutter test` may prompt to select a device if multiple are available. Prefer specifying a device non-interactively with `-d <device-id>`.

- **Temporary CI change (2025-11-30):** Integration tests (TI) are temporarily disabled in CI to avoid failing runs while we prepare emulator setup for the runners. The job in `.github/workflows/integration-tests.yml` has been disabled by adding `if: false`. To re-enable TI in CI, remove the `if: false` line and add steps to install SDK components and boot an AVD as documented above.

Local commands (PowerShell examples):
```powershell
# From repository root, run in frontend
Push-Location 'C:\Projects\croiz\frontend'
flutter pub get

# Run a single integration test on an Android device/emulator (non-interactive)
flutter test integration_test/app_test.dart -d <device-id>

# Or run all integration tests
flutter test integration_test/
Pop-Location
```

Prerequisites for local TI:
- Android SDK / Android Studio (for `emulator`, `sdkmanager`, `avdmanager`).
- Or a physical Android device with USB debugging enabled.

Quick emulator setup (Windows PowerShell example):
```powershell
# Set your Android SDK root if not already set
$env:ANDROID_SDK_ROOT = 'C:\Users\<YourUser>\AppData\Local\Android\Sdk'

# Install required SDK components (requires sdkmanager in PATH)
## Quick Start

# Create an AVD named 'test_avd'


# Launch the emulator (may take a minute to boot)
### Prerequisites
- Flutter 3.38+ with Dart 3.10+
```

CI recommendation:
- If you want GitHub Actions to run TI non-interactively, add steps in `.github/workflows/integration-tests.yml` to install Android SDK components, create and boot an AVD, and wait for the emulator to become ready before running `flutter test`.
- Example (Ubuntu runner) — skeleton snippet to integrate into the workflow:
```yaml
- name: Install Android SDK
	run: |
		sudo apt-get update
		sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients
		yes | sdkmanager --install "platform-tools" "platforms;android-33" "system-images;android-33;google_apis;x86_64" "emulator"

- name: Create and start AVD
	run: |
		echo no | avdmanager create avd -n test_avd -k "system-images;android-33;google_apis;x86_64" --force
		$ANDROID_SDK_ROOT/emulator/emulator -avd test_avd -no-window -no-audio &
		adb wait-for-device
		adb shell 'while [[ $(getprop sys.boot_completed) != "1" ]]; do sleep 1; done'
```
- Java 21 LTS
- PostgreSQL 14+
- Git

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

### Backend Setup
```bash
cd backend
./gradlew bootRun
# or
mvn spring-boot:run
```

## Documentation

- [Architecture](docs/architecture.md)
- [API Documentation](docs/api.md)
- [Setup Guide](docs/setup.md)
- [Testing Strategy](docs/testing.md)
- [Database Schema](docs/database.md)

## License

Private repository - All rights reserved

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
