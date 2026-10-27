# Android setup script

Flutter-focused helper for STUDCONNECT on Android.

## Requirements

- Flutter 3.24+
- Android Studio / SDK + `adb`
- JDK 17
- Optional: GitHub CLI (`gh`) to download release ZIPs

## Quick start

```bash
git clone https://github.com/TamakloeAndrews/GROKSTUDCONNECT.git
cd GROKSTUDCONNECT
chmod +x scripts/setup-android.sh

./scripts/setup-android.sh doctor
./scripts/setup-android.sh install
# Copy STUDCONNECT-MOBILE-Android-iOS-v0.9.zip into ~/GROKSTUDCONNECT/artifacts/ if needed
./scripts/setup-android.sh extract
./scripts/setup-android.sh prepare
# Start API on PC port 8080, then:
./scripts/setup-android.sh run
```

Or: `./scripts/setup-android.sh all`

## Commands

| Command | Action |
|---------|--------|
| `doctor` | `flutter doctor` + adb devices |
| `install` | Clone repo; download mobile/source ZIPs |
| `extract` | Unzip into `work/android-app` |
| `prepare` | `flutter create` (android) + `pub get` |
| `devices` | List devices |
| `run` | Run on emulator/device (`API_BASE` default `http://10.0.2.2:8080`) |
| `build-debug` | Debug APK |
| `build` | Release APK |
| `build-aab` | Play Store bundle |
| `install-apk` | `adb install -r` latest APK |

## Physical device

```bash
API_BASE_DEVICE=http://192.168.1.20:8080 ./scripts/setup-android.sh run
```

## Production API URL for release builds

```bash
API_BASE_PROD=https://api.yourdomain.com ./scripts/setup-android.sh build
API_BASE_PROD=https://api.yourdomain.com ./scripts/setup-android.sh build-aab
```

Configure `android/key.properties` before store release (see `docs/HOW_TO_BUILD_APK.md`).
