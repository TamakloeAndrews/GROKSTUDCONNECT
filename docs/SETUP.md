# Local setup script

Download and run STUDCONNECT (web + API) from this repository.

## One-liner (after cloning)

```bash
git clone https://github.com/TamakloeAndrews/GROKSTUDCONNECT.git
cd GROKSTUDCONNECT
chmod +x scripts/setup-studconnect.sh
```

## Put source ZIPs in place

If Release assets are published:

```bash
./scripts/setup-studconnect.sh install
```

Or copy these files into `~/GROKSTUDCONNECT/artifacts/`:

- `STUDCONNECT-COMPLETE-v0.9.1-SOURCE.zip`
- `STUDCONNECT-WEB-v0.9.zip` (optional)

Then:

```bash
./scripts/setup-studconnect.sh extract
./scripts/setup-studconnect.sh run
```

Open **http://127.0.0.1:3000** (API on **8080**).

## Commands

| Command | Action |
|---------|--------|
| `install` | Clone/update repo; try `gh release download` |
| `extract` | Unzip source + web into `work/` |
| `api` | Start reference server only |
| `web` | Start web UI + `/v1` proxy only |
| `run` | API + web together |
| `mobile-hint` | Flutter run instructions |
| `all` | install → extract → run |

## Requirements

- `git`, `curl`, `unzip`, **Node.js 22+**
- Optional: `gh` (GitHub CLI) for automatic release downloads
- Optional: Flutter for Android/iOS (`mobile-hint`)
