# IMPLEMENTATION_STATE.md — current checkpoint (2026-11-16)

**STATUS: PAUSED by the owner after Phase 2.** Nothing is in progress and no branch is open. To resume read `HANDOFF.md` first.
Older detail: `archive/2026-11-15_phase1_state.md`. Rules: `ENGINEERING_RULES.md`. Per-feature statuses: `implementation.md`.

## Baselines
- `main` = Phase 1 + Phase 2, merged at the owner's approval on 2026-11-16 (see `git log` or the tag `phase2-paused-2026-11-16`).
- The last code change is commit `5520f0b3886dab010e7cc216b11439d11c49c978`. The owner installed the APK built from it (artifact `android-apk` of that CI run) and approved the result overall. Every later commit changes documentation only.
- applicationId `com.moamen.addady`, Flutter 3.47.9 pinned in `.github/workflows/build-apk.yml`, gateway `Flutter-Android-Build@v1.0.0`.

## What exists (Phase 1 + Phase 2)
Meters (electricity, water, gas; place; unit), readings with a reset/replacement tag, consumption per period, spike detection against a threshold, in-app alert bell, home / add-reading / analytics screens, drawer (meter management and editing, local tariff and cost estimate, alert threshold, local notifications switch, language Arabic/English, theme, CSV export). 100% local, no accounts, no network use. Local notifications: spike alert once per latest reading, "reading due" reminder 30 days after the latest reading at 09:00.

## What does NOT exist (honest list)
Photo evidence per reading · PDF export · bundled Arabic font (system font is used) · release signing (shared debug key) · `LICENSE` file (the README refers to one) · committed `pubspec.lock` (cannot be produced without Flutter) · exact pin of `share_plus` (currently `^11.0.0`).

## Verification levels reached
- Sanity: 61 pure-Dart tests run locally with a plain Dart SDK (domain logic, notification planning, tariff, CSV, strings, language).
- CI (GitHub Actions): every commit compiled, analyzed (clean) and tested (15 Flutter-dependent tests run only there), then built a release APK. Last green: 5520f0b.
- Owner's device: installed 5520f0b, approved overall ("رائع"). Item-by-item device results (real notification delivery, reminder after a reboot, share sheet and CSV in a spreadsheet app, English layout, cost estimate with a real tariff) were NOT reported, so those items stay "Implemented, not yet verified" in `implementation.md`.

## Open items / next (priority order)
1. Owner: report which Phase 2 features behave on the phone (see the test list in `HANDOFF.md`).
2. Photo evidence per reading (needs design decisions 6 and 7).
3. PDF export (needs a bundled Arabic font and text shaping).
4. Card/widget sizes differ from the design (owner feedback; the design skills are being reviewed in another conversation).
5. Housekeeping: pin `share_plus` exactly, commit a `pubspec.lock` (generate it where Flutter is available or from CI), add the `LICENSE` the README mentions (the owner decides the license).
6. Release signing and publication later.

## Build log
1 first build · green · 39fbc54 (PR) · package com.moamen.eaddady (obsolete)
2 Phase 1 on main · green · 0e89188 (owner merge) and b2d6f57 (docs)
3 Phase 2 · green · 57dc072 (notifications + rename to addady), a77ea47 (tariff), e9fb982 (language), 5520f0b (export) — the owner's installed build
4 closing documentation commits and the merge into main · see `CHANGELOG.md`
