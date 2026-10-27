#!/usr/bin/env bash
# STUDCONNECT setup — download packages and run locally (web + API)
# Repo: https://github.com/TamakloeAndrews/GROKSTUDCONNECT
set -euo pipefail

REPO_URL="${STUDCONNECT_REPO:-https://github.com/TamakloeAndrews/GROKSTUDCONNECT.git}"
REPO_DIR="${STUDCONNECT_DIR:-$HOME/GROKSTUDCONNECT}"
ARTIFACTS_DIR="${STUDCONNECT_ARTIFACTS:-$REPO_DIR/artifacts}"
API_PORT="${API_PORT:-8080}"
WEB_PORT="${WEB_PORT:-3000}"
RELEASE_TAG="${RELEASE_TAG:-v0.9.1-source}"
RELEASE_ASSET="${RELEASE_ASSET:-STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip}"
WEB_TAG="${WEB_TAG:-v0.9-web}"
WEB_ASSET="${WEB_ASSET:-STUDCONNECT-WEB-v0.9.zip}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[STUDCONNECT]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC} $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; }

need() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }
}

usage() {
  cat <<USAGE
STUDCONNECT local setup

Usage: $0 <command>

Commands:
  install     Clone repo, fetch latest source/web release zips (if available)
  extract     Unzip complete source + web package into workdirs
  api         Start reference API on port ${API_PORT}
  web         Start web UI on port ${WEB_PORT} (proxies /v1 → API)
  run         Start API + web together (Ctrl+C stops both)
  mobile-hint Print Flutter commands for Android/iOS
  all         install → extract → run
  help        Show this help

Environment:
  STUDCONNECT_DIR       Working directory (default: ~/GROKSTUDCONNECT)
  STUDCONNECT_ARTIFACTS Where ZIPs are stored (default: \$STUDCONNECT_DIR/artifacts)
  API_PORT              Default 8080
  WEB_PORT              Default 3000
  RELEASE_TAG / RELEASE_ASSET   Complete source release
  WEB_TAG / WEB_ASSET           Web package release

Examples:
  $0 all
  API_PORT=8080 WEB_PORT=3000 $0 run
USAGE
}

cmd_install() {
  need git
  need curl
  mkdir -p "$ARTIFACTS_DIR"
  if [[ -d "$REPO_DIR/.git" ]]; then
    info "Updating repo at $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only || warn "git pull failed — continuing with existing clone"
  else
    info "Cloning $REPO_URL → $REPO_DIR"
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  if command -v gh >/dev/null 2>&1; then
    info "Downloading release assets with gh (if published)…"
    gh release download "$RELEASE_TAG" -R TamakloeAndrews/GROKSTUDCONNECT \
      -p "$RELEASE_ASSET" -D "$ARTIFACTS_DIR" --clobber 2>/dev/null \
      && info "Got $RELEASE_ASSET" \
      || warn "Release $RELEASE_TAG / $RELEASE_ASSET not on GitHub yet — place ZIP in $ARTIFACTS_DIR manually"
    gh release download "$WEB_TAG" -R TamakloeAndrews/GROKSTUDCONNECT \
      -p "$WEB_ASSET" -D "$ARTIFACTS_DIR" --clobber 2>/dev/null \
      && info "Got $WEB_ASSET" \
      || warn "Web release not found — optional"
  else
    warn "gh CLI not installed. Clone is ready; download ZIPs from Releases in the browser into:"
    echo "  $ARTIFACTS_DIR"
    echo "  https://github.com/TamakloeAndrews/GROKSTUDCONNECT/releases"
  fi
  info "Install step done."
}

cmd_extract() {
  mkdir -p "$REPO_DIR/work"
  local src_zip="$ARTIFACTS_DIR/$RELEASE_ASSET"
  local web_zip="$ARTIFACTS_DIR/$WEB_ASSET"

  if [[ -f "$src_zip" ]]; then
    info "Extracting $RELEASE_ASSET → $REPO_DIR/work/source"
    rm -rf "$REPO_DIR/work/source"
    mkdir -p "$REPO_DIR/work/source"
    unzip -q -o "$src_zip" -d "$REPO_DIR/work/source"
    info "Source extracted."
  else
    warn "No $src_zip — skip full source extract. Put the complete source ZIP in $ARTIFACTS_DIR"
  fi

  if [[ -f "$web_zip" ]]; then
    info "Extracting web package → $REPO_DIR/work/web"
    rm -rf "$REPO_DIR/work/web"
    mkdir -p "$REPO_DIR/work/web"
    unzip -q -o "$web_zip" -d "$REPO_DIR/work/web"
    info "Web package extracted."
  else
    if [[ -d "$REPO_DIR/work/source/studconnect/apps/web" ]]; then
      info "Using web from extracted monorepo"
    else
      warn "No web ZIP and no monorepo web path yet."
    fi
  fi
}

find_source_root() {
  local c
  c=$(find "$REPO_DIR/work/source" -maxdepth 3 -type d -name 'reference-server' 2>/dev/null | head -1)
  if [[ -n "${c:-}" ]]; then
    dirname "$(dirname "$c")"
    return
  fi
  c=$(find "$REPO_DIR/work/source" -maxdepth 2 -type d -name 'studconnect' 2>/dev/null | head -1)
  echo "${c:-}"
}

find_web_public() {
  if [[ -d "$REPO_DIR/work/web/studconnect-web-package/public" ]]; then
    echo "$REPO_DIR/work/web/studconnect-web-package/public"
    return
  fi
  if [[ -d "$REPO_DIR/work/web/public" ]]; then
    echo "$REPO_DIR/work/web/public"
    return
  fi
  local root
  root=$(find_source_root)
  if [[ -n "$root" && -d "$root/apps/web" ]]; then
    echo "$root/apps/web"
    return
  fi
  echo ""
}

find_serve_mjs() {
  if [[ -f "$REPO_DIR/work/web/studconnect-web-package/serve.mjs" ]]; then
    echo "$REPO_DIR/work/web/studconnect-web-package/serve.mjs"
    return
  fi
  if [[ -f "$REPO_DIR/work/web/serve.mjs" ]]; then
    echo "$REPO_DIR/work/web/serve.mjs"
    return
  fi
  echo ""
}

cmd_api() {
  need node
  local root
  root=$(find_source_root)
  if [[ -z "$root" ]]; then
    err "Source not extracted. Run: $0 install && $0 extract"
    exit 1
  fi
  local server="$root/apps/reference-server"
  if [[ ! -d "$server" ]]; then
    err "reference-server not found under $root"
    exit 1
  fi
  info "Starting API from $server (port $API_PORT)"
  cd "$server"
  if [[ -f package.json ]]; then
    if [[ ! -d node_modules ]]; then
      info "npm install…"
      npm install
    fi
    export PORT="$API_PORT"
    if npm run start --if-present 2>/dev/null; then
      exit 0
    fi
  fi
  if [[ -f src/main.ts ]]; then
    PORT="$API_PORT" node --experimental-strip-types src/main.ts
  elif [[ -f src/index.ts ]]; then
    PORT="$API_PORT" node --experimental-strip-types src/index.ts
  elif [[ -f dist/main.js ]]; then
    PORT="$API_PORT" node dist/main.js
  else
    err "Could not find how to start reference-server."
    exit 1
  fi
}

write_fallback_serve() {
  local out=$1
  cat > "$out" <<'JS'
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PUBLIC = process.env.WEB_PUBLIC || path.join(__dirname, 'public');
const PORT = Number(process.env.WEB_PORT || process.env.PORT || 3000);
const API = process.env.API_URL || 'http://127.0.0.1:8080';

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.ico': 'image/x-icon',
  '.webmanifest': 'application/manifest+json',
  '.svg': 'image/svg+xml',
};

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || '/', `http://127.0.0.1:${PORT}`);
  if (url.pathname.startsWith('/v1') || url.pathname.startsWith('/health')) {
    const target = API + url.pathname + url.search;
    const headers = { ...req.headers, host: new URL(API).host };
    delete headers['content-length'];
    const chunks = [];
    for await (const c of req) chunks.push(c);
    const body = Buffer.concat(chunks);
    try {
      const r = await fetch(target, { method: req.method, headers, body: body.length ? body : undefined });
      const buf = Buffer.from(await r.arrayBuffer());
      const outH = {};
      r.headers.forEach((v, k) => { if (k !== 'transfer-encoding') outH[k] = v; });
      res.writeHead(r.status, outH);
      res.end(buf);
    } catch (e) {
      res.writeHead(502, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ message: 'API unreachable: ' + e.message }));
    }
    return;
  }
  let p = url.pathname === '/' ? '/index.html' : url.pathname;
  const filePath = path.join(PUBLIC, path.normalize(p).replace(/^(\.\.(\/|\\|$))+/, ''));
  if (!filePath.startsWith(PUBLIC) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    res.writeHead(404); res.end('Not found'); return;
  }
  const ext = path.extname(filePath);
  res.writeHead(200, { 'content-type': MIME[ext] || 'application/octet-stream' });
  fs.createReadStream(filePath).pipe(res);
});

server.listen(PORT, () => {
  console.log(`STUDCONNECT web http://127.0.0.1:${PORT}`);
  console.log(`Proxying /v1 → ${API}`);
});
JS
}

cmd_web() {
  need node
  local public
  public=$(find_web_public)
  if [[ -z "$public" ]]; then
    err "Web public folder not found. Run: $0 extract"
    exit 1
  fi
  local serve
  serve=$(find_serve_mjs)
  info "Web static root: $public"
  export WEB_PORT="$WEB_PORT" PORT="$WEB_PORT"
  export API_URL="http://127.0.0.1:${API_PORT}"
  export WEB_PUBLIC="$public"
  if [[ -n "$serve" ]]; then
    cd "$(dirname "$serve")"
    if [[ ! -d public ]]; then ln -sfn "$public" public; fi
    API_URL="$API_URL" PORT="$WEB_PORT" node "$(basename "$serve")"
  else
    mkdir -p "$REPO_DIR/work/web-runtime"
    write_fallback_serve "$REPO_DIR/work/web-runtime/serve.mjs"
    ln -sfn "$public" "$REPO_DIR/work/web-runtime/public"
    cd "$REPO_DIR/work/web-runtime"
    WEB_PUBLIC="$public" API_URL="$API_URL" PORT="$WEB_PORT" node serve.mjs
  fi
}

cmd_run() {
  need node
  local root
  root=$(find_source_root)
  if [[ -z "$root" ]]; then
    err "Run: $0 install && $0 extract first"
    exit 1
  fi
  info "Starting API on :$API_PORT and web on :$WEB_PORT"
  info "Open http://127.0.0.1:$WEB_PORT when both are up"
  ( cmd_api ) &
  API_PID=$!
  cleanup() { kill "$API_PID" 2>/dev/null || true; wait "$API_PID" 2>/dev/null || true; }
  trap cleanup EXIT INT TERM
  sleep 2
  cmd_web
}

cmd_mobile_hint() {
  cat <<HINT
Flutter mobile — after extract:

  cd apps/mobile   # under extracted studconnect source

  flutter create . --project-name studconnect \\
    --org technology.stonecode.studconnect --platforms=android,ios
  flutter pub get
  flutter run -d android --dart-define=API_BASE=http://10.0.2.2:$API_PORT
  flutter run -d ios --dart-define=API_BASE_IOS=http://127.0.0.1:$API_PORT

Docs: https://github.com/TamakloeAndrews/GROKSTUDCONNECT
HINT
}

cmd_all() {
  cmd_install
  cmd_extract
  cmd_run
}

main() {
  local cmd=${1:-help}
  case "$cmd" in
    install) cmd_install ;;
    extract) cmd_extract ;;
    api) cmd_api ;;
    web) cmd_web ;;
    run) cmd_run ;;
    mobile-hint|mobile) cmd_mobile_hint ;;
    all) cmd_all ;;
    help|-h|--help) usage ;;
    *) err "Unknown command: $cmd"; usage; exit 1 ;;
  esac
}

main "$@"
