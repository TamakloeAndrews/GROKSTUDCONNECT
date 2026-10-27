# GROKSTUDCONNECT

**STUDCONNECT** source packages and guides built with Grok for **STONECODE TECHNOLOGY**.

Ghana-first learning + social platform for ages **12+**, with guardian controls, policy-enforced safety, Flutter (Android/iOS), web PWA, and reference API.

**Repository owner:** [TamakloeAndrews](https://github.com/TamakloeAndrews)  
**Repo URL:** https://github.com/TamakloeAndrews/GROKSTUDCONNECT

---

## What is in this repo

| Path | Description |
|------|-------------|
| [`RELEASES.md`](./RELEASES.md) | All package ZIP names tagged by version / creation |
| [`docs/`](./docs/) | Flutter production guide, APK how-to |

Binary **`.zip` archives** (full source trees) should be published as **[GitHub Release assets](https://github.com/TamakloeAndrews/GROKSTUDCONNECT/releases)** so Git stays lean. See `RELEASES.md` for exact filenames and tags.

---

## Recommended packages (latest)

| Tag | File | Purpose |
|-----|------|---------|
| `v0.9.1-source` | `STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip` | Full monorepo (API, mobile, web, policy, docs) |
| `v0.9-mobile` | `STUDCONNECT-MOBILE-Android-iOS-v0.9.zip` | Flutter Android + iOS project package |
| `v0.9-web` | `STUDCONNECT-WEB-v0.9.zip` | Web/PWA client + local serve proxy |
| `v0.9.0-mobile-source` | `STUDCONNECT-COMPLETE-v0.9.0-MOBILE-SOURCE.zip` | Monorepo at first mobile layer merge |

---

## Quick start

1. Download the **v0.9.1** complete source ZIP from Releases (upload from your Grok artifacts if not yet attached).  
2. Follow **`docs/FLUTTER_DEV_AND_PRODUCTION_GUIDE.md`**.  
3. API: `apps/reference-server` (dev) → NestJS `apps/api` (production).  
4. Mobile: `apps/mobile` → `flutter create` / `flutter build apk|appbundle|ipa`.

---

## Product notes

- Server-side **policy-rules** enforce age, tier isolation, adult-to-minor contact bans.  
- Guardians control screen time, AI, video limits, consent.  
- Stud+ about GHS 15/month; LIVE gifts adult-only.  
- Play Store / App Store publishing steps are in the Flutter guide.

---

*Packages generated with Grok · STONECODE TECHNOLOGY · STUDCONNECT*
