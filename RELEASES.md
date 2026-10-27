# GROKSTUDCONNECT — Release inventory (creation tags)

Each row is a build artifact produced during the Grok STUDCONNECT sessions.  
**Tag** = recommended GitHub Release tag. **Filename** = asset name to upload.

## Complete monorepo source

| Tag | Filename | Created (approx) | Notes |
|-----|----------|------------------|--------|
| `v0.8.0-source` | `STUDCONNECT-COMPLETE-v0.8-SOURCE.zip` | 2026-10-15 | Baseline complete source |
| `v0.8.1-source` | `STUDCONNECT-COMPLETE-v0.8.1-SOURCE.zip` | 2026-10-15 | Incremental |
| `v0.8.2-source` | `STUDCONNECT-COMPLETE-v0.8.2-SOURCE.zip` | 2026-10-15 | Incremental |
| `v0.8.3-source` | `STUDCONNECT-COMPLETE-v0.8.3-SOURCE.zip` | 2026-10-15 | Incremental |
| `v0.8.4-source` | `STUDCONNECT-COMPLETE-v0.8.4-SOURCE.zip` | 2026-10-17 | Incremental |
| `v0.8.5-source` | `STUDCONNECT-COMPLETE-v0.8.5-SOURCE.zip` | 2026-10-17 | Incremental |
| `v0.8.6-source` | `STUDCONNECT-COMPLETE-v0.8.6-SOURCE.zip` | 2026-10-18 | Incremental |
| `v0.8.7-source` | `STUDCONNECT-COMPLETE-v0.8.7-SOURCE.zip` | 2026-10-18 | Incremental |
| `v0.8.8-source` | `STUDCONNECT-COMPLETE-v0.8.8-SOURCE.zip` | 2026-10-18 | Security / live path |
| `v0.8.9-source` | `STUDCONNECT-COMPLETE-v0.8.9-SOURCE.zip` | 2026-10-18 | Profile views |
| `v0.8.10-source` | `STUDCONNECT-COMPLETE-v0.8.10-SOURCE.zip` | 2026-10-18 | Video view alerts |
| `v0.8.11-source` | `STUDCONNECT-COMPLETE-v0.8.11-SOURCE.zip` | 2026-10-18 | Name cooldown, video limits |
| `v0.8.12-source` | `STUDCONNECT-COMPLETE-v0.8.12-SOURCE.zip` | 2026-10-18 | Feed likes/comments UX |
| `v0.8.13-source` | `STUDCONNECT-COMPLETE-v0.8.13-SOURCE.zip` | 2026-10-19 | About, tutorials, forgot password |
| `v0.8.14-source` | `STUDCONNECT-COMPLETE-v0.8.14-SOURCE.zip` | 2026-10-19 | Tutorial replay + tutor UI |
| `v0.9.0-mobile-source` | `STUDCONNECT-COMPLETE-v0.9.0-MOBILE-SOURCE.zip` | 2026-10-19 | Flutter app layer |
| **`v0.9.1-source`** | **`STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip`** | **2026-10-19** | **Latest full monorepo + platforms** |

## Feature-specific / interim packages

| Tag | Filename | Created | Notes |
|-----|----------|---------|--------|
| `v0.7-media-design` | `studconnect-media-voice-video-v0.7-design.zip` | 2026-10-15 | Media design pack |
| `v0.7-app` | `studconnect-app-v0.7.zip` | 2026-10-15 | App snapshot |
| `v0.7.1-studio` | `studconnect-app-v0.7.1-studio.zip` | 2026-10-15 | Creator Studio |
| `v0.8-live` | `studconnect-app-v0.8-live.zip` | 2026-10-15 | LIVE / gifts |

## Mobile and web distribution packages

| Tag | Filename | Created | Notes |
|-----|----------|---------|--------|
| **`v0.9-mobile`** | **`STUDCONNECT-MOBILE-Android-iOS-v0.9.zip`** | **2026-10-19** | Flutter Android + iOS scaffold |
| **`v0.9-web`** | **`STUDCONNECT-WEB-v0.9.zip`** | **2026-10-19** | Web PWA + serve.mjs |

## Docs (in docs/ on main)

| File | Purpose |
|------|---------|
| `FLUTTER_DEV_AND_PRODUCTION_GUIDE.md` | Full Flutter to production guide |
| `HOW_TO_BUILD_APK.md` | APK build steps |

## Attach ZIP binaries as GitHub Release assets

```bash
gh release create v0.9.1-source STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip \
  --repo TamakloeAndrews/GROKSTUDCONNECT \
  --title "v0.9.1 Complete source" \
  --notes "Full STUDCONNECT monorepo."

gh release create v0.9-mobile STUDCONNECT-MOBILE-Android-iOS-v0.9.zip \
  --repo TamakloeAndrews/GROKSTUDCONNECT \
  --title "v0.9 Mobile Android+iOS"

gh release create v0.9-web STUDCONNECT-WEB-v0.9.zip \
  --repo TamakloeAndrews/GROKSTUDCONNECT \
  --title "v0.9 Web package"
```

Or: GitHub website → Releases → Draft a new release → upload files.

Binary ZIPs are best stored as **Release assets**, not as normal git blobs.
