#!/usr/bin/env bash
# STUDCONNECT — iOS setup (Flutter, macOS only)
# Repo: https://github.com/TamakloeAndrews/GROKSTUDCONNECT
set -euo pipefail

REPO_URL="${STUDCONNECT_REPO:-https://github.com/TamakloeAndrews/GROKSTUDCONNECT.git}"
REPO_DIR="${STUDCONNECT_DIR:-$HOME/GROKSTUDCONNECT}"
ARTIFACTS_DIR="${STUDCONNECT_ARTIFACTS:-$REPO_DIR/artifacts}"
MOBILE_TAG="${MOBILE_TAG:-v0.9-mobile}"
MOBILE_ASSET="${MOBILE_ASSET:-STUDCONNECT-MOBILE-Android-iOS-v0.9.zip}"
SOURCE_TAG="${SOURCE_TAG:-v0.9.1-source}"
SOURCE_ASSET="${SOURCE_ASSET:-STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip}"
API_BASE_IOS="${API_BASE_IOS:-http://127.0.0.1:8080}"
API_BASE_PROD="${API_BASE_PROD:-https://api.yourdomain.com}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[ios]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC} $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; }

need() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing: $1"; exit 1; }
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    err "iOS builds require macOS with Xcode."
    err "On Linux/Windows use: scripts/setup-android.sh"
    exit 1
  fi
}

usage() {
  cat <<USAGE
STUDCONNECT iOS setup (Flutter · macOS + Xcode only)

Usage: $0 <command>

Commands:
  doctor      Check Flutter, Xcode, CocoaPods
  install     Clone GROKSTUDCONNECT; download mobile/source ZIPs if possible
  extract     Unzip mobile (or complete source) → work/ios-app
  prepare     flutter create (ios) + pub get + pod install
  devices     List Flutter / simulator devices
  run         Run on iOS Simulator (or connected device)
  build       flutter build ios --release
  build-ipa   flutter build ipa --release (for TestFlight / App Store)
  open-xcode  Open ios/Runner.xcworkspace in Xcode
  all         doctor → install → extract → prepare → run
  help        This help

Environment:
  STUDCONNECT_DIR     Default: ~/GROKSTUDCONNECT
  API_BASE_IOS        Default: http://127.0.0.1:8080 (simulator → host API)
  API_BASE_PROD       HTTPS API for release / IPA builds

Examples:
  $0 all
  API_BASE_IOS=http://127.0.0.1:8080 $0 run
  API_BASE_PROD=https://api.yourdomain.com $0 build-ipa
USAGE
}

find_mobile_dir() {
  local d
  d=$(find "$REPO_DIR/work/ios-app" -maxdepth 3 -type f -name pubspec.yaml 2>/dev/null | head -1)
  if [[ -n "${d:-}" ]]; then dirname "$d"; return; fi
  d=$(find "$REPO_DIR/work" -maxdepth 5 -type f -name pubspec.yaml 2>/dev/null | head -1)
  if [[ -n "${d:-}" ]]; then dirname "$d"; return; fi
  d=$(find "$REPO_DIR/work/source" -maxdepth 6 -type d -path '*/apps/mobile' 2>/dev/null | head -1)
  if [[ -n "${d:-}" && -f "$d/pubspec.yaml" ]]; then echo "$d"; return; fi
  echo ""
}

cmd_doctor() {
  require_macos
  info "Checking toolchain…"
  if ! command -v flutter >/dev/null 2>&1; then
    err "Flutter not found. Install: https://docs.flutter.dev/get-started/install/macos"
    exit 1
  fi
  flutter --version | head -3
  echo ""
  flutter doctor -v || true
  echo ""
  if command -v xcodebuild >/dev/null 2>&1; then
    info "Xcode: $(xcodebuild -version 2>/dev/null | head -1)"
  else
    err "Xcode not found. Install from App Store, then xcode-select + accept license."
  fi
  if command -v pod >/dev/null 2>&1; then
    info "CocoaPods: $(pod --version)"
  else
    warn "CocoaPods missing: sudo gem install cocoapods  OR  brew install cocoapods"
  fi
  info "Doctor done."
}

cmd_install() {
  need git
  mkdir -p "$ARTIFACTS_DIR"
  if [[ -d "$REPO_DIR/.git" ]]; then
    info "Updating $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only || warn "pull failed"
  else
    info "Cloning $REPO_URL"
    git clone "$REPO_URL" "$REPO_DIR"
  fi
  if command -v gh >/dev/null 2>&1; then
    gh release download "$MOBILE_TAG" -R TamakloeAndrews/GROKSTUDCONNECT \
      -p "$MOBILE_ASSET" -D "$ARTIFACTS_DIR" --clobber 2>/dev/null \
      && info "Downloaded $MOBILE_ASSET" \
      || warn "Copy $MOBILE_ASSET into $ARTIFACTS_DIR manually"
    gh release download "$SOURCE_TAG" -R TamakloeAndrews/GROKSTUDCONNECT \
      -p "$SOURCE_ASSET" -D "$ARTIFACTS_DIR" --clobber 2>/dev/null || true
  else
    warn "Place ZIPs in $ARTIFACTS_DIR"
  fi
}

cmd_extract() {
  mkdir -p "$REPO_DIR/work"
  local mobile_zip="$ARTIFACTS_DIR/$MOBILE_ASSET"
  local source_zip="$ARTIFACTS_DIR/$SOURCE_ASSET"
  if [[ -f "$mobile_zip" ]]; then
    info "Extracting mobile package…"
    rm -rf "$REPO_DIR/work/mobile-pkg"
    mkdir -p "$REPO_DIR/work/mobile-pkg"
    unzip -q -o "$mobile_zip" -d "$REPO_DIR/work/mobile-pkg"
    local found
    found=$(find "$REPO_DIR/work/mobile-pkg" -name pubspec.yaml | head -1)
    if [[ -n "$found" ]]; then
      rm -rf "$REPO_DIR/work/ios-app"
      cp -a "$(dirname "$found")" "$REPO_DIR/work/ios-app"
      info "iOS project → $REPO_DIR/work/ios-app"
    fi
  elif [[ -f "$source_zip" ]]; then
    info "Extracting complete source…"
    rm -rf "$REPO_DIR/work/source"
    mkdir -p "$REPO_DIR/work/source"
    unzip -q -o "$source_zip" -d "$REPO_DIR/work/source"
    local m
    m=$(find "$REPO_DIR/work/source" -type d -path '*/apps/mobile' | head -1)
    if [[ -n "$m" ]]; then
      rm -rf "$REPO_DIR/work/ios-app"
      cp -a "$m" "$REPO_DIR/work/ios-app"
      info "iOS project → $REPO_DIR/work/ios-app"
    else
      err "apps/mobile not found"; exit 1
    fi
  else
    err "No mobile/source ZIP in $ARTIFACTS_DIR"; exit 1
  fi
}

cmd_prepare() {
  require_macos
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract first"; exit 1; }
  info "Project: $app"
  cd "$app"
  flutter create . --project-name studconnect --org technology.stonecode.studconnect --platforms=ios || warn "create issues"
  flutter pub get
  if [[ -d ios ]] && command -v pod >/dev/null 2>&1; then
    info "pod install…"
    (cd ios && pod install) || warn "pod install failed"
  fi
  info "Prepare done. Use open-xcode to set Signing Team."
}

cmd_devices() {
  need flutter
  flutter devices
  command -v xcrun >/dev/null && xcrun simctl list devices available 2>/dev/null | head -40 || true
}

cmd_run() {
  require_macos
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  info "API_BASE_IOS=$API_BASE_IOS"
  cd "$app"
  if command -v xcrun >/dev/null 2>&1; then
    local booted
    booted=$(xcrun simctl list devices | grep -c "(Booted)" || true)
    if [[ "${booted:-0}" -eq 0 ]]; then
      local udid
      udid=$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/{print $(NF-1); exit}')
      if [[ -n "${udid:-}" ]]; then
        xcrun simctl boot "$udid" 2>/dev/null || true
        open -a Simulator 2>/dev/null || true
        sleep 3
      fi
    fi
  fi
  flutter run -d ios --dart-define=API_BASE_IOS="$API_BASE_IOS" --dart-define=API_BASE="$API_BASE_IOS"
}

cmd_build() {
  require_macos
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  cd "$app"
  flutter build ios --release --dart-define=API_BASE="$API_BASE_PROD" --dart-define=API_BASE_IOS="$API_BASE_PROD"
  info "See build/ios/ — open Runner.xcworkspace for signing"
}

cmd_build_ipa() {
  require_macos
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  cd "$app"
  flutter build ipa --release --dart-define=API_BASE="$API_BASE_PROD" --dart-define=API_BASE_IOS="$API_BASE_PROD" || {
    warn "Configure Team in Xcode Signing & Capabilities, then retry"
    exit 1
  }
  info "IPA: $app/build/ios/ipa/"
  ls -la "$app/build/ios/ipa/" 2>/dev/null || true
}

cmd_open_xcode() {
  require_macos
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  local ws="$app/ios/Runner.xcworkspace"
  if [[ -d "$ws" ]]; then open "$ws"
  elif [[ -d "$app/ios/Runner.xcodeproj" ]]; then open "$app/ios/Runner.xcodeproj"
  else err "No Xcode project"; exit 1
  fi
}

cmd_all() {
  cmd_doctor
  cmd_install
  cmd_extract
  cmd_prepare
  cmd_run
}

main() {
  local cmd=${1:-help}
  case "$cmd" in
    doctor) cmd_doctor ;;
    install) cmd_install ;;
    extract) cmd_extract ;;
    prepare) cmd_prepare ;;
    devices) cmd_devices ;;
    run) cmd_run ;;
    build) cmd_build ;;
    build-ipa) cmd_build_ipa ;;
    open-xcode) cmd_open_xcode ;;
    all) cmd_all ;;
    help|-h|--help) usage ;;
    *) err "Unknown: $cmd"; usage; exit 1 ;;
  esac
}

main "$@"
