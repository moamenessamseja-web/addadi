# Changelog (completed work only — never plans)

## 2026-11-16 — closing
- Project paused after Phase 2. `.agent/` rewritten to the true state (done / not done), Phase 1 state archived, repository map and lessons written, Phase 2 merged into `main` at the owner's approval, tag `phase2-paused-2026-11-16`.

## 2026-11-16 — Phase 2 (branch agent/phase2-notifications, all CI-green)
- 57dc072: package renamed to `addady` (applicationId `com.moamen.addady`); local notifications (spike alert once per latest reading, 30-day reading reminder, preference switch, Android 13 permission handling); native setup in `tool/ci_android.sh` (permissions, boot/scheduled receivers, desugaring, R8 keep rules) based on manager-assistant-ready d2a17ef.
- a77ea47: meter editing; local tariff with progressive tiers and a cost estimate on the Analytics screen.
- e9fb982: language selection Arabic / English (live switch, one tested bilingual string table).
- 5520f0b: CSV export through the Android share sheet (`share_plus ^11.0.0`). The owner installed the APK of this commit.

## 2026-11-15 and 2026-11-16 — Phase 1
- 39fbc54: first app on CI-green: pure-Dart domain (consumption, reset segments, spike detection, validation) with unit tests, local storage, Home / Add reading / Analytics screens, drawer, alert bell, light and dark themes, Arabic RTL with numeric runs left-to-right.
- 1a84986: AGENTS.md added. Merged into `main` as 0e89188 (merge via the API by an actor authenticated as the owner's account; the owner reported not having merged it, so another agent using the same token is likely: rotate the token). Docs follow-ups: b2d6f57.
