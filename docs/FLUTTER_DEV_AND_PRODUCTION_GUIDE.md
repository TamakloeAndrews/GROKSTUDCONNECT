# STUDCONNECT — Full Flutter Development & Production Guide

**Product:** STUDCONNECT by STONECODE TECHNOLOGY  
**Platforms:** Android (APK / AAB) and iOS (IPA) from **one Flutter codebase**  
**Audience:** Engineers, founders, and release managers  

This guide assumes the monorepo under `apps/mobile` (Flutter) and an API under `apps/reference-server` (dev) or `apps/api` (NestJS production target).

Full detailed guide was generated during the Grok STUDCONNECT build. For the complete text (local build, signing, Play Store, Ghana gates), keep a copy of:

- `STUDCONNECT-Flutter-Dev-Production-Guide.md` from your Grok artifacts download, or
- Re-download from the conversation file card.

## Quick command summary

```bash
cd apps/mobile
flutter create . --project-name studconnect --org technology.stonecode.studconnect --platforms=android,ios
flutter pub get

# Dev
flutter run -d android --dart-define=API_BASE=http://10.0.2.2:8080

# Tests
flutter analyze && flutter test

# Release APK / AAB (after configuring key.properties signing)
flutter build apk --release --dart-define=API_BASE=https://api.yourdomain.com
flutter build appbundle --release --dart-define=API_BASE=https://api.yourdomain.com

# iOS (macOS)
flutter build ipa --release --dart-define=API_BASE=https://api.yourdomain.com
```

## Signing (production APK)

```bash
keytool -genkey -v -keystore studconnect-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias studconnect
```

Create `android/key.properties` (gitignored) and wire `signingConfigs.release` in Gradle. Upload **AAB** to Play Console with Play App Signing.

## Publish to Google Play

1. Build signed AAB  
2. Play Console → Create app → Data safety, content rating, privacy policy  
3. Upload AAB → internal/closed testing → production staged rollout  

See also: `docs/HOW_TO_BUILD_APK.md` and `RELEASES.md` for package tags.

*STONECODE TECHNOLOGY · STUDCONNECT · Grok*
