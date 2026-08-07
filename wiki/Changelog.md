# Changelog

## 1.0.0 — Native iOS + Fancy 3D Docs (2026-08-07)

**App:** SwiftUI + SwiftData + Vision on device. Trips (destination/dates/activities/climate/status), packing lists (categories/qty/packed/essential/progress/search), personal library (photo/favorite/reuse), Vision Scanner (`VNClassifyImageRequest` confirm-before-add), Outfit Planner (dayLabel), Dashboard (upcoming/progress/missing), Global Search, Templates (5 starters + custom), Reminders (`UserNotifications`), Settings. Light/Dark, Dynamic Type, VoiceOver, iPhone + iPad.

**Build:** Xcode 16 + `macos-15` + `xcodegen generate` → `PackWise.xcodeproj`. Tests: `PackWiseTests` (Swift Testing) + `PackWiseUITests`. IPA: `xcodebuild archive` + `DerivedData` fallback → `Payload/PackWise.app` → `PackWise-unsigned.ipa` + `.sha256`. Three hosts: GitHub Actions / Gitea Actions / `act` locally (`.actrc`). Non-blocking tests (`continue-on-error` + `if: always()`) so [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) can’t block the IPA again. Release on `v*` tag.

**Docs — 3D + deep + live-combined:**
- ProgramREADME  program�: `assets/packwise-hero.svg` (isometric suitcase, 3 layers), `assets/architecture.svg` (pipeline), `assets/og-image.svg` (1200×630) — all hand-written SVG, not screenshots
- This Wiki (8 pages) synced from `wiki/` via `.github/workflows/wiki.yml` to `Alot1z/packwise.wiki`
- Live Freebuff Preview site (`src/`) — Warm Athena Vite app that imports `assets/*.svg` and links to `Alot1z/packwise/releases` + `…/actions` — README + Wiki + site stay in sync without copy-paste

**Privacy:** On device, offline, no cloud, no account, no tracking. MIT.
