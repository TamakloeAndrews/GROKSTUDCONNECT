# GROKSTUDCONNECT

**STUDCONNECT** source packages and guides built with Grok for **STONECODE TECHNOLOGY**.

Ghana-first learning + social platform for ages **12+**, with guardian controls, policy-enforced safety, Flutter (Android/iOS), web PWA, and reference API.

**Repo:** https://github.com/TamakloeAndrews/GROKSTUDCONNECT

---

## Quick setup (download & run)

```bash
git clone https://github.com/TamakloeAndrews/GROKSTUDCONNECT.git
cd GROKSTUDCONNECT
chmod +x scripts/setup-studconnect.sh

# 1) Fetch repo (+ release ZIPs if published with gh)
./scripts/setup-studconnect.sh install

# 2) Put complete source ZIP in ~/GROKSTUDCONNECT/artifacts/ if not downloaded:
#    STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip
./scripts/setup-studconnect.sh extract

# 3) Run API (8080) + web (3000)
./scripts/setup-studconnect.sh run
```

Open **http://127.0.0.1:3000**

Full commands: [`docs/SETUP.md`](./docs/SETUP.md) · script: [`scripts/setup-studconnect.sh`](./scripts/setup-studconnect.sh)

Flutter mobile: `./scripts/setup-studconnect.sh mobile-hint`

---

## Packages & tags

See [`RELEASES.md`](./RELEASES.md) for every ZIP filename and creation tag (`v0.9.1-source`, `v0.9-mobile`, `v0.9-web`, …).

Upload binaries as **GitHub Release assets** (see `scripts/upload-release-zips.sh`).

---

## Docs

| Doc | Topic |
|-----|--------|
| `docs/SETUP.md` | Local download & run |
| `docs/HOW_TO_BUILD_APK.md` | Android APK |
| `docs/FLUTTER_DEV_AND_PRODUCTION_GUIDE.md` | Flutter → production |

---

*STONECODE TECHNOLOGY · STUDCONNECT · Grok*
