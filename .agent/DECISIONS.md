# DECISIONS.md — owner decisions, engineer decisions, frozen items, open questions

## Decided by the owner
- 2026-11-15: app name Ɛaddady (عَدّادي); repo moamenessamseja-web/addadi; offline-first, no accounts (README).
- 2026-11-16: package name `addady`; Phase 2 order: notifications, then the remaining drawer items (meter configuration and tariff, language, export).
- 2026-11-16: the owner installed the APK of 5520f0b and approved the result overall. This accepts the engineer decisions below as the working baseline; any single one can still be overruled.
- 2026-11-16: the project is paused; the next work comes from another conversation.

## Engineer decisions (numbered; the first one is the only hard-to-change item)
1. **applicationId = `com.moamen.addady`** (pubspec name `addady` + `--org com.moamen`), changed from `com.moamen.eaddady` on 2026-11-16 at the owner's request before the second install (the owner removes the old app). It cannot change again after the next install without uninstalling.
2. **Storage (design open decision 8): `shared_preferences`, one JSON document** (meters, readings, settings). Text only, fine for this volume. Photos will need files later.
3. **Spike baseline (design 5):** compare the consumption of the latest period with the period before it (raw consumption, not per day). Needs >= 3 readings in the current segment (two historical readings plus the current one). Baseline of exactly 0 gives no percentage (no spike claimed). Both periods' dates are shown.
4. **Reading frequency (design 2):** arbitrary intervals; a meter is "due" when its latest reading is more than 30 days old. A new reading cannot be older than the latest one of that meter.
5. **Precision (design 1):** any number of typed decimals is accepted; shown with at most 2 decimals; negative numbers rejected; Arabic-Indic digits typed by the user are accepted.
6. **Property (design 3):** a free-text "place" on each meter (title "كهرباء — الشقة"); no separate property entity or selector yet.
7. **Font:** the Android system font (design asks to confirm IBM Plex Sans Arabic / Noto Sans Arabic availability first). Not bundled in Phase 1.
8. **Digits in system dialogs:** the Material date/time pickers follow the Arabic locale and may show Arabic-Indic digits; readings, dates on cards and percentages are Latin LTR. To be checked on the device.
9. **Notifications are local only** (flutter_local_notifications 17.2.4 + timezone 0.9.4, pinned: the exact versions that built in CI and ran on the owner's phone in manager-assistant-ready). Two kinds: a spike alert shown immediately when a saved reading creates a spike, and a "reading due" reminder scheduled for 30 days after the latest reading at 09:00 (re-armed on every save, settings change and app start; not scheduled when already overdue, the in-app bell covers that).
10. **No duplicates:** one spike notification per meter per latest reading id (persisted); a newer reading that is still a spike alerts again. Lowering the threshold does not alert retroactively.
11. **Inexact alarms on purpose** (`inexactAllowWhileIdle`): no `SCHEDULE_EXACT_ALARM` permission, so no special permission screen; a reminder may arrive a few minutes late. Android 13+ `POST_NOTIFICATIONS` is requested once automatically after the first saved reading while the preference is on, and again whenever the owner switches the toggle on.
12. **Preference vs OS permission are separate:** the drawer switch is the app preference; its subtitle says when the OS blocks notifications and how to allow them. A notification failure never fails a saved reading.
13. **Native setup lives in `tool/ci_android.sh`** (CI-generated `android/`): permissions, boot + scheduled receivers, core-library desugaring, R8 keep rules, copied from the proven manager-assistant-ready pipeline minus the exact-alarm permission.
14. **Tariff model (design open decision 4):** per meter: a currency label, an optional fixed fee per period, and progressive tiers with cumulative upper limits (for example up to 100 units at price A, up to 300 at price B, the rest at price C); only the last tier is open. The estimate is applied to the consumption of one reading period. If the owner's real tariff works differently (for example the price of the whole consumption set by the tier it falls in), say so and this model changes.
15. **Language:** Arabic and English, switched live from the drawer and remembered; one global language code in the pure domain, one bilingual string table (tested). English mirrors the layout left-to-right. Numbers and dates stay Latin in both.
16. **Export:** CSV only for now (UTF-8 with a byte-order mark so Arabic opens correctly in spreadsheets; dot decimals, no thousands separators; text cells that start with = + - @ are neutralised). One row per reading; "period consumption" is blank for the first reading and after a reset. PDF is deferred: it needs a bundled Arabic font and shaping. Photos are not exported because photos do not exist yet.
17. **Plugin note:** `share_plus` is `^11.0.0` (not an exact pin) because pub.dev could not be reached to confirm exact versions; the earlier app has no share/export code to copy. Pin it exactly once the first green build shows the resolved version.

## Frozen / out of scope until the owner says so
- Release signing (the debug key shared across the owner's apps is used for now).
- Photo evidence, PDF export, bundled Arabic font: not started (see Open decisions).

## Open decisions (need the owner; smallest options)
- Photo evidence (design 6 and 7): camera only or gallery too; does the export include the photo files or only references.
- PDF export: needs a bundled Arabic font and text shaping; decide whether it is worth it.
- Tariff semantics: decision 14 assumes progressive tiers per reading period; confirm against the owner's real bills.
- Design card/widget sizes: the owner reported they differ from the design foundation (design skills are being reviewed elsewhere).
- License: the README says MIT and refers to a `LICENSE` file that does not exist. The owner decides.

## Prior art in the owner other repositories (read before building notifications)
- **Notifications / reminders: `moamenessamseja-web/manager-assistant-ready`, commit `d2a17efe50efb9c715525433aaca44ad8e3e700d`** (2026-10-22, recorded at the owner request). Per its commit message the earlier problems were: scheduling ran only on app open and created reminders for past occurrences (so nothing future was ever scheduled), scheduling was inexact only, and recurrence was ignored. The fix there: a testable notification backend, exact alarms when the user allows them (inexact fallback clearly flagged), recurring reminders as a pre-scheduled series (30 daily / 26 weekly / 12 monthly) refreshed on every app open, and CI injecting `SCHEDULE_EXACT_ALARM` into the manifest. Status: read from the commit message only; the code was not reviewed or reused yet. For this app it maps to the monthly reading reminder and spike alerts (design 8).
