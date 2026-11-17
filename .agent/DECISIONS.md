# DECISIONS.md — owner decisions, frozen items, open questions

## Decided (by the owner)
- 2026-11-15 — app name Ɛaddady (عَدّادي); repo moamenessamseja-web/addadi; offline-first, no accounts (README).

## Decided by the engineer in Phase 1 (owner may overrule; each is small to change except the first)
1. **applicationId = `com.moamen.addady`** (pubspec name `addady` + `--org com.moamen`), changed from `com.moamen.eaddady` on 2026-11-16 at the owner's request before the second install (the owner removes the old app). It cannot change again after the next install without uninstalling.
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

## Phase 2 decisions (engineer; owner may overrule)
9. **Notifications are local only** (flutter_local_notifications 17.2.4 + timezone 0.9.4, pinned: the exact versions that built in CI and ran on the owner's phone in manager-assistant-ready). Two kinds: a spike alert shown immediately when a saved reading creates a spike, and a "reading due" reminder scheduled for 30 days after the latest reading at 09:00 (re-armed on every save, settings change and app start; not scheduled when already overdue, the in-app bell covers that).
10. **No duplicates:** one spike notification per meter per latest reading id (persisted); a newer reading that is still a spike alerts again. Lowering the threshold does not alert retroactively.
11. **Inexact alarms on purpose** (`inexactAllowWhileIdle`): no `SCHEDULE_EXACT_ALARM` permission, so no special permission screen; a reminder may arrive a few minutes late. Android 13+ `POST_NOTIFICATIONS` is requested once automatically after the first saved reading while the preference is on, and again whenever the owner switches the toggle on.
12. **Preference vs OS permission are separate:** the drawer switch is the app preference; its subtitle says when the OS blocks notifications and how to allow them. A notification failure never fails a saved reading.
13. **Native setup lives in `tool/ci_android.sh`** (CI-generated `android/`): permissions, boot + scheduled receivers, core-library desugaring, R8 keep rules, copied from the proven manager-assistant-ready pipeline minus the exact-alarm permission.
14. **Tariff model (design open decision 4):** per meter: a currency label, an optional fixed fee per period, and progressive tiers with cumulative upper limits (for example up to 100 units at price A, up to 300 at price B, the rest at price C); only the last tier is open. The estimate is applied to the consumption of one reading period. If the owner's real tariff works differently (for example the price of the whole consumption set by the tier it falls in), say so and this model changes.
