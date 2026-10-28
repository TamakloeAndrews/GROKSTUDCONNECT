# STUDCONNECT Lite (PWA)

A **lightweight progressive web app** in the spirit of Facebook Lite / Instagram Lite / TikTok Lite:

- Runs in **any modern browser**
- **Installable** to the home screen
- **Low data**: system fonts, ~14KB JS, no framework CDN
- Text feed, likes, rooms, text posts — same `/v1` safety API

## Package

Download `STUDCONNECT-LITE-PWA-v1.zip` from artifacts/Releases, or use files under a `studconnect-lite/` folder.

```bash
cd studconnect-lite
# API on :8080
node serve.mjs   # http://127.0.0.1:3001
```

Deploy: host `public/` statically; reverse-proxy `/v1` to the API over HTTPS.

## vs full app

Lite omits video/Reels, LIVE, Studio, AI, and heavy media. Server policy still applies.
