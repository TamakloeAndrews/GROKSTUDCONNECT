#!/usr/bin/env bash
# Upload Grok STUDCONNECT ZIP artifacts as GitHub Releases (run on your machine).
set -euo pipefail
REPO=TamakloeAndrews/GROKSTUDCONNECT
DIR=${1:-.}
cd "$DIR"

upload() {
  local tag=$1 file=$2 title=$3
  if [[ ! -f "$file" ]]; then echo "skip missing $file"; return; fi
  if gh release view "$tag" --repo "$REPO" &>/dev/null; then
    gh release upload "$tag" "$file" --repo "$REPO" --clobber
  else
    gh release create "$tag" "$file" --repo "$REPO" --title "$title" --notes "STUDCONNECT package $tag"
  fi
  echo "OK $tag <- $file"
}

upload v0.9.1-source STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip "v0.9.1 Complete source"
upload v0.9.0-mobile-source STUDCONNECT-COMPLETE-v0.9.0-MOBILE-SOURCE.zip "v0.9.0 Mobile source"
upload v0.9-mobile STUDCONNECT-MOBILE-Android-iOS-v0.9.zip "v0.9 Mobile Android+iOS"
upload v0.9-web STUDCONNECT-WEB-v0.9.zip "v0.9 Web"
upload v0.8.14-source STUDCONNECT-COMPLETE-v0.8.14-SOURCE.zip "v0.8.14 Complete source"
upload v0.8.13-source STUDCONNECT-COMPLETE-v0.8.13-SOURCE.zip "v0.8.13 Complete source"
upload v0.8.12-source STUDCONNECT-COMPLETE-v0.8.12-SOURCE.zip "v0.8.12 Complete source"
upload v0.8.11-source STUDCONNECT-COMPLETE-v0.8.11-SOURCE.zip "v0.8.11 Complete source"
upload v0.8.10-source STUDCONNECT-COMPLETE-v0.8.10-SOURCE.zip "v0.8.10 Complete source"
upload v0.8.9-source STUDCONNECT-COMPLETE-v0.8.9-SOURCE.zip "v0.8.9 Complete source"
upload v0.8.8-source STUDCONNECT-COMPLETE-v0.8.8-SOURCE.zip "v0.8.8 Complete source"
upload v0.8.7-source STUDCONNECT-COMPLETE-v0.8.7-SOURCE.zip "v0.8.7 Complete source"
upload v0.8.6-source STUDCONNECT-COMPLETE-v0.8.6-SOURCE.zip "v0.8.6 Complete source"
upload v0.8.5-source STUDCONNECT-COMPLETE-v0.8.5-SOURCE.zip "v0.8.5 Complete source"
upload v0.8.4-source STUDCONNECT-COMPLETE-v0.8.4-SOURCE.zip "v0.8.4 Complete source"
upload v0.8.3-source STUDCONNECT-COMPLETE-v0.8.3-SOURCE.zip "v0.8.3 Complete source"
upload v0.8.2-source STUDCONNECT-COMPLETE-v0.8.2-SOURCE.zip "v0.8.2 Complete source"
upload v0.8.1-source STUDCONNECT-COMPLETE-v0.8.1-SOURCE.zip "v0.8.1 Complete source"
upload v0.8.0-source STUDCONNECT-COMPLETE-v0.8-SOURCE.zip "v0.8.0 Complete source"
upload v0.8-live studconnect-app-v0.8-live.zip "v0.8 LIVE"
upload v0.7.1-studio studconnect-app-v0.7.1-studio.zip "v0.7.1 Studio"
upload v0.7-app studconnect-app-v0.7.zip "v0.7 App"
upload v0.7-media-design studconnect-media-voice-video-v0.7-design.zip "v0.7 Media design"

echo Done. See https://github.com/$REPO/releases
