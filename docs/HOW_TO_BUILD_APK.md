# How to build the STUDCONNECT Android APK

This environment does **not** ship a pre-built `.apk` binary: an APK must be compiled with the **Flutter SDK** and Android SDK on your machine (or CI).

## Requirements

- Flutter 3.24+ (`flutter doctor`)
- Android Studio / Android SDK (API 34+)
- JDK 17 recommended for Android Gradle
- Device or emulator (optional for install)

## Steps

```bash
# 1. Open the mobile app
cd apps/mobile

# 2. Align platform projects with your Flutter SDK
flutter create . --project-name studconnect --org technology.stonecode.studconnect --platforms=android,ios

# 3. Dependencies
flutter pub get

# 4. API base URL
# Emulator → host machine API:
#   http://10.0.2.2:8080
# Physical device → your PC LAN IP:
#   http://192.168.x.x:8080
# Production:
#   https://api.yourdomain.com

# 5. Debug APK (faster)
flutter build apk --debug --dart-define=API_BASE=http://10.0.2.2:8080

# 6. Release APK
flutter build apk --release --dart-define=API_BASE=https://api.yourdomain.com

# 7. Play Store bundle (recommended for store)
flutter build appbundle --release --dart-define=API_BASE=https://api.yourdomain.com
```

## Output paths

| Artifact | Path |
|----------|------|
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` |

## Install on a phone

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## One-shot script

```bash
export API_BASE=https://api.yourdomain.com
./scripts/build_mobile.sh android
```

## Signing (release)

Replace debug signing in `android/app/build.gradle.kts` with a release keystore before Play Store upload. Never commit keystore passwords to git.

## CI example (GitHub Actions outline)

```yaml
- uses: subosito/flutter-action@v2
  with: { flutter-version: '3.24.0' }
- run: flutter pub get
- run: flutter build apk --release --dart-define=API_BASE=${{ secrets.API_BASE }}
- uses: actions/upload-artifact@v4
  with: { name: studconnect-apk, path: build/app/outputs/flutter-apk/*.apk }
```
