# DECISIONS.md — owner decisions, frozen items, open questions

## Decided (by the owner)
- 2026-11-15 — app name Ɛaddady (عَدّادي); repo moamenessamseja-web/addadi; offline-first, no accounts (README).

## Decided by the engineer in Phase 1 (owner may overrule; each is small to change except the first)
1. **applicationId = `com.moamen.eaddady`** (from pubspec name `eaddady` + `--org com.moamen`). Cannot change after the first install on the phone without uninstalling. Owner to confirm BEFORE installing the first APK.
2. **Storage (design open decision 8): `shared_preferences`, one JSON document** (meters, readings, settings). Text only, fine for this volume. Photos will need files later.
3. **Spike baseline (design 5):** compare the consumption of the latest period with the period before it (raw consumption, not per day). Needs >= 3 readings in the current segment (two historical readings plus the current one). Baseline of exactly 0 gives no percentage (no spike claimed). Both periods' dates are shown.
4. **Reading frequency (design 2):** arbitrary intervals; a meter is "due" when its latest reading is more than 30 days old. A new reading cannot be older than the latest one of that meter.
5. **Precision (design 1):** any number of typed decimals is accepted; shown with at most 2 decimals; negative numbers rejected; Arabic-Indic digits typed by the user are accepted.
6. **Property (design 3):** a free-text "place" on each meter (title "كهرباء — الشقة"); no separate property entity or selector yet.
7. **Font:** the Android system font (design asks to confirm IBM Plex Sans Arabic / Noto Sans Arabic availability first). Not bundled in Phase 1.
8. **Digits in system dialogs:** the Material date/time pickers follow the Arabic locale and may show Arabic-Indic digits; readings, dates on cards and percentages are Latin LTR. To be checked on the device.

## Frozen / out of scope until the owner says so
- Release signing (debug key shared across the owner's apps is used for now).

## Open decisions (need the owner; smallest options)
- Design 4: tariff representation (flat price per unit, or tiers?) — needed for the cost estimate.
- Design 6 and 7: photo from camera only, or gallery too; does the export include photo files or only references.
- Local notifications: Android 13+ permission flow and wording.
- Language switch: Arabic only for now (README mentions language selection).

## Prior art in the owner other repositories (read before building notifications)
- **Notifications / reminders: `moamenessamseja-web/manager-assistant-ready`, commit `d2a17efe50efb9c715525433aaca44ad8e3e700d`** (2026-10-22, recorded at the owner request). Per its commit message the earlier problems were: scheduling ran only on app open and created reminders for past occurrences (so nothing future was ever scheduled), scheduling was inexact only, and recurrence was ignored. The fix there: a testable notification backend, exact alarms when the user allows them (inexact fallback clearly flagged), recurring reminders as a pre-scheduled series (30 daily / 26 weekly / 12 monthly) refreshed on every app open, and CI injecting `SCHEDULE_EXACT_ALARM` into the manifest. Status: read from the commit message only; the code was not reviewed or reused yet. For this app it maps to the monthly reading reminder and spike alerts (design 8).

