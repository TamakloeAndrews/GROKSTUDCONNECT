# iOS setup script

Flutter helper for STUDCONNECT on **iOS**. Requires **macOS + Xcode**.

## Requirements

- macOS
- Xcode 15+ (license accepted, command-line tools)
- Flutter 3.24+
- CocoaPods (`pod`)
- Optional: `gh` to download release ZIPs

## Quick start

```bash
git clone https://github.com/TamakloeAndrews/GROKSTUDCONNECT.git
cd GROKSTUDCONNECT
chmod +x scripts/setup-ios.sh

./scripts/setup-ios.sh doctor
./scripts/setup-ios.sh install
# Copy STUDCONNECT-MOBILE-Android-iOS-v0.9.zip into ~/GROKSTUDCONNECT/artifacts/ if needed
./scripts/setup-ios.sh extract
./scripts/setup-ios.sh prepare   # flutter create + pub get + pod install

# Start API on this Mac :8080, then:
./scripts/setup-ios.sh run       # iOS Simulator, API_BASE_IOS=http://127.0.0.1:8080
```

Or: `./scripts/setup-ios.sh all`

## Commands

| Command | Action |
|---------|--------|
| `doctor` | Flutter doctor, Xcode, CocoaPods |
| `install` | Clone repo; download ZIPs |
| `extract` | Unzip into `work/ios-app` |
| `prepare` | `flutter create --platforms=ios`, `pub get`, `pod install` |
| `devices` | Flutter devices + simulators |
| `run` | Run on Simulator / device |
| `build` | `flutter build ios --release` |
| `build-ipa` | IPA for TestFlight / App Store |
| `open-xcode` | Open `Runner.xcworkspace` |

## Signing / TestFlight

```bash
./scripts/setup-ios.sh open-xcode
# Signing & Capabilities → select your Apple Developer Team
API_BASE_PROD=https://api.yourdomain.com ./scripts/setup-ios.sh build-ipa
```

Upload the IPA with Transporter or Xcode Organizer.

## Notes

- Simulator talks to API on the Mac via `http://127.0.0.1:8080`.
- Physical device needs your Mac’s LAN IP and ATS/cleartext exceptions only for dev.
- Production builds must use HTTPS `API_BASE_PROD`.
- iOS cannot fully block screenshots; do not claim otherwise in store copy.
