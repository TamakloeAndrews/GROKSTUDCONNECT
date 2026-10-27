#!/usr/bin/env bash
# STUDCONNECT — Android setup (Flutter)
# Repo: https://github.com/TamakloeAndrews/GROKSTUDCONNECT
set -euo pipefail

REPO_URL="${STUDCONNECT_REPO:-https://github.com/TamakloeAndrews/GROKSTUDCONNECT.git}"
REPO_DIR="${STUDCONNECT_DIR:-$HOME/GROKSTUDCONNECT}"
ARTIFACTS_DIR="${STUDCONNECT_ARTIFACTS:-$REPO_DIR/artifacts}"
MOBILE_TAG="${MOBILE_TAG:-v0.9-mobile}"
MOBILE_ASSET="${MOBILE_ASSET:-STUDCONNECT-MOBILE-Android-iOS-v0.9.zip}"
SOURCE_TAG="${SOURCE_TAG:-v0.9.1-source}"
SOURCE_ASSET="${SOURCE_ASSET:-STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip}"
API_BASE_EMULATOR="${API_BASE_EMULATOR:-http://10.0.2.2:8080}"
API_BASE_DEVICE="${API_BASE_DEVICE:-}"
API_BASE_PROD="${API_BASE_PROD:-https://api.yourdomain.com}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[android]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC} $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; }

need() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing: $1"; exit 1; }
}

usage() {
  cat <<USAGE
STUDCONNECT Android setup (Flutter)

Usage: $0 <command>

Commands:
  doctor      Check Flutter / Android toolchain
  install     Clone GROKSTUDCONNECT; download mobile/source ZIPs if possible
  extract     Unzip mobile (or complete source) → work/android-app
  prepare     flutter create + pub get in the mobile project
  devices     List Flutter devices
  run         Run on a connected Android device/emulator
  build-debug Build debug APK
  build       Build release APK (needs signing for store)
  build-aab   Build Play Store App Bundle
  install-apk Install latest debug/release APK via adb
  all         doctor → install → extract → prepare → run
  help        This help

Environment:
  STUDCONNECT_DIR          Default: ~/GROKSTUDCONNECT
  API_BASE_EMULATOR        Default: http://10.0.2.2:8080
  API_BASE_DEVICE          Your PC LAN IP, e.g. http://192.168.1.20:8080
  API_BASE_PROD            Production HTTPS API for release builds

Examples:
  $0 all
  API_BASE_DEVICE=http://192.168.1.20:8080 $0 run
  $0 build-debug
USAGE
}

find_mobile_dir() {
  local d
  d=$(find "$REPO_DIR/work" -maxdepth 5 -type f -name pubspec.yaml 2>/dev/null | head -1)
  if [[ -n "${d:-}" ]]; then
    dirname "$d"
    return
  fi
  d=$(find "$REPO_DIR/work/source" -maxdepth 6 -type d -path '*/apps/mobile' 2>/dev/null | head -1)
  if [[ -n "${d:-}" && -f "$d/pubspec.yaml" ]]; then
    echo "$d"
    return
  fi
  echo ""
}

api_base_for_run() {
  if [[ -n "${API_BASE_DEVICE}" ]]; then
    echo "$API_BASE_DEVICE"
    return
  fi
  echo "$API_BASE_EMULATOR"
}

cmd_doctor() {
  info "Checking toolchain…"
  if ! command -v flutter >/dev/null 2>&1; then
    err "Flutter not found. Install: https://docs.flutter.dev/get-started/install"
    err "Then: flutter doctor --android-licenses"
    exit 1
  fi
  flutter --version | head -3
  echo ""
  flutter doctor -v || true
  echo ""
  if command -v adb >/dev/null 2>&1; then
    info "adb devices:"
    adb devices -l || true
  else
    warn "adb not on PATH (install Android SDK platform-tools)"
  fi
  info "Doctor done. Fix any Flutter doctor errors before build/run."
}

cmd_install() {
  need git
  mkdir -p "$ARTIFACTS_DIR"
  if [[ -d "$REPO_DIR/.git" ]]; then
    info "Updating $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only || warn "pull failed — using existing clone"
  else
    info "Cloning $REPO_URL"
    git clone "$REPO_URL" "$REPO_DIR"
  fi
  if command -v gh >/dev/null 2>&1; then
    gh release download "$MOBILE_TAG" -R TamakloeAndrews/GROKSTUDCONNECT \
      -p "$MOBILE_ASSET" -D "$ARTIFACTS_DIR" --clobber 2>/dev/null \
      && info "Downloaded $MOBILE_ASSET" \
      || warn "Mobile release not on GitHub yet — copy $MOBILE_ASSET into $ARTIFACTS_DIR"
    gh release download "$SOURCE_TAG" -R TamakloeAndrews/GROKSTUDCONNECT \
      -p "$SOURCE_ASSET" -D "$ARTIFACTS_DIR" --clobber 2>/dev/null \
      && info "Downloaded $SOURCE_ASSET" \
      || true
  else
    warn "Install GitHub CLI (gh) for auto download, or place ZIPs in:"
    echo "  $ARTIFACTS_DIR/$MOBILE_ASSET"
    echo "  $ARTIFACTS_DIR/$SOURCE_ASSET"
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
      rm -rf "$REPO_DIR/work/android-app"
      cp -a "$(dirname "$found")" "$REPO_DIR/work/android-app"
      info "Mobile project → $REPO_DIR/work/android-app"
    fi
  elif [[ -f "$source_zip" ]]; then
    info "Extracting complete source (for apps/mobile)…"
    rm -rf "$REPO_DIR/work/source"
    mkdir -p "$REPO_DIR/work/source"
    unzip -q -o "$source_zip" -d "$REPO_DIR/work/source"
    local m
    m=$(find "$REPO_DIR/work/source" -type d -path '*/apps/mobile' | head -1)
    if [[ -n "$m" ]]; then
      rm -rf "$REPO_DIR/work/android-app"
      cp -a "$m" "$REPO_DIR/work/android-app"
      info "Mobile project → $REPO_DIR/work/android-app"
    else
      err "apps/mobile not found inside source ZIP"
      exit 1
    fi
  else
    err "No $MOBILE_ASSET or $SOURCE_ASSET in $ARTIFACTS_DIR"
    exit 1
  fi
}

cmd_prepare() {
  need flutter
  local app
  app=$(find_mobile_dir)
  if [[ -z "$app" ]]; then
    err "No Flutter project found. Run: $0 extract"
    exit 1
  fi
  info "Project: $app"
  cd "$app"
  info "flutter create (align platforms with your SDK)…"
  flutter create . \
    --project-name studconnect \
    --org technology.stonecode.studconnect \
    --platforms=android \
    || warn "flutter create reported issues — continuing"
  info "flutter pub get…"
  flutter pub get
  info "Prepare done."
}

cmd_devices() {
  need flutter
  flutter devices
}

cmd_run() {
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  local base
  base=$(api_base_for_run)
  info "API_BASE=$base"
  info "Start the STUDCONNECT API on your PC (port 8080) before login works."
  cd "$app"
  flutter run --dart-define=API_BASE="$base"
}

cmd_build_debug() {
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  local base
  base=$(api_base_for_run)
  cd "$app"
  info "Building debug APK (API_BASE=$base)…"
  flutter build apk --debug --dart-define=API_BASE="$base"
  info "APK: $app/build/app/outputs/flutter-apk/app-debug.apk"
}

cmd_build() {
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  cd "$app"
  if [[ ! -f android/key.properties ]]; then
    warn "android/key.properties not found — release may use debug signing."
    warn "See docs/HOW_TO_BUILD_APK.md for production keystore setup."
  fi
  info "Building release APK (API_BASE=$API_BASE_PROD)…"
  flutter build apk --release --dart-define=API_BASE="$API_BASE_PROD"
  info "APK: $app/build/app/outputs/flutter-apk/app-release.apk"
}

cmd_build_aab() {
  need flutter
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "Run extract + prepare first"; exit 1; }
  cd "$app"
  info "Building App Bundle (API_BASE=$API_BASE_PROD)…"
  flutter build appbundle --release --dart-define=API_BASE="$API_BASE_PROD"
  info "AAB: $app/build/app/outputs/bundle/release/app-release.aab"
}

cmd_install_apk() {
  need adb
  local app
  app=$(find_mobile_dir)
  [[ -n "$app" ]] || { err "No project"; exit 1; }
  local apk=""
  for c in \
    "$app/build/app/outputs/flutter-apk/app-release.apk" \
    "$app/build/app/outputs/flutter-apk/app-debug.apk"
  do
    [[ -f "$c" ]] && { apk=$c; break; }
  done
  if [[ -z "$apk" ]]; then
    err "No APK found. Run: $0 build-debug   or   $0 build"
    exit 1
  fi
  info "Installing $apk"
  adb install -r "$apk"
}

cmd_all() {
  cmd_doctor
  cmd_install
  cmd_extract
  cmd_prepare
  info "Starting app (ensure API is running on host :8080)…"
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
    build-debug) cmd_build_debug ;;
    build) cmd_build ;;
    build-aab) cmd_build_aab ;;
    install-apk) cmd_install_apk ;;
    all) cmd_all ;;
    help|-h|--help) usage ;;
    *) err "Unknown: $cmd"; usage; exit 1 ;;
  esac
}

main "$@"
