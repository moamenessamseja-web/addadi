# implementation.md — inventory of what exists (honest statuses)

Statuses (use ONLY these, never promote without evidence): **Verified complete** · **Implemented, not yet verified** · **Partially implemented** ·
**Not started** · **Blocked** · **Deferred by product decision**.
Evidence levels: *read* < *sanity* < *CI* < *artifact inspected* < *owner's device*. "Verified complete" needs the owner's device for anything user-facing.

Owner's device evidence so far: Phase 1 build was installed and tested by the owner (everything functional; card/widget sizes differ from the design). The Phase 2 build 5520f0b was installed and approved overall, without item-level results, so Phase 2 items keep the status below until the owner reports them.

## 1. Domain logic (pure Dart)
| Item | Status | Notes (evidence, build, limits) |
|---|---|---|
| Consumption per period, segments split at reset/replacement | Implemented, not yet verified | sanity: unit tests run locally with plain Dart (25 cases passed); CI green on 39fbc54 (see the verification log) |
| Spike detection (threshold, needs 2 historical readings, no comparison across a reset) | Implemented, not yet verified | sanity as above; baseline definition is an engineer decision (DECISIONS 3) |
| Entry validation (negative, lower than previous without reset tag, older date) | Implemented, not yet verified | sanity as above |
| Number parsing (Arabic-Indic digits) and formatting (Latin, LTR runs) | Implemented, not yet verified | sanity as above |

## 2. Storage
| Item | Status | Notes (evidence, build, limits) |
|---|---|---|
| Local persistence of meters, readings, settings (shared_preferences JSON) | Implemented, not yet verified | widget tests use an in-memory store; the real Android storage is only exercised on the device |

## 3. Screens
| Item | Status | Notes (evidence, build, limits) |
|---|---|---|
| Meters home: overview counts, one card per meter, statuses, empty state | Implemented, not yet verified | needs the owner's device (layout, Arabic wrapping) |
| Add reading: meter selector, previous reading, numeric field, date/time, reset toggle with confirmation, calculation preview, save feedback | Implemented, not yet verified | needs the owner's device |
| Analytics: comparison, per-period line chart, daily rate, empty states | Implemented, not yet verified | chart is a CustomPaint; needs the owner's device |
| Alert bell (in-app list of spikes and due readings) | Implemented, not yet verified | |
| Drawer: meter management with delete confirmation, alert threshold, theme | Partially implemented | language switch, export and notification preference are not there |
| Add meter sheet | Implemented, not yet verified | |
| RTL layout with numeric runs left-to-right, light and dark themes | Implemented, not yet verified | date/time pickers may show Arabic-Indic digits (DECISIONS 8) |

## 3b. Notifications (Phase 2)
| Item | Status | Notes (evidence, build, limits) |
|---|---|---|
| Spike notification, once per latest reading | Implemented, not yet verified | sanity: unit + store tests (fake backend); real delivery needs the owner's device |
| "Reading due" reminder (30 days after the latest reading, 09:00) | Implemented, not yet verified | scheduled with inexact alarms; needs the owner's device and time |
| Notification preference switch + OS permission handling | Implemented, not yet verified | Android 13+ permission dialog; needs the owner's device |
| Native setup (permissions, receivers, desugaring, R8 rules) via tool/ci_android.sh | Implemented, not yet verified | dry-run on a mock project only; CI is the first real run |

## 3c. Meter configuration and local tariff (Phase 2)
| Item | Status | Notes (evidence, build, limits) |
|---|---|---|
| Edit a meter (place, unit) | Implemented, not yet verified | store test; UI needs the owner's device |
| Local tariff (progressive tiers, fixed fee, currency label) and the cost estimate on the Analytics screen | Implemented, not yet verified | sanity: 51 pure-Dart tests incl. tier boundaries; always labelled an estimate; hidden until a tariff is set |

## 3d. Language and export (Phase 2)
| Item | Status | Notes (evidence, build, limits) |
|---|---|---|
| Language selection, Arabic and English (live switch, direction follows, remembered) | Implemented, not yet verified | CI green (analyze, widget test of the switch); string table tested: every key has both languages; needs the owner's device |
| CSV export of all readings through the Android share sheet | Implemented, not yet verified | CSV builder tested (BOM, quoting, formula neutralising, plain numbers); the share_plus plugin API/version could not be checked offline: CI is the first compile |
| PDF export | Deferred by product decision | needs a bundled Arabic font and text shaping; not started |

## 4. Not built yet
| Item | Status | Notes (evidence, build, limits) |
|---|---|---|
| Photo evidence per reading | Not started | needs decisions 6 and 7 (camera/gallery, export) |
| PDF export | Deferred by product decision | needs a bundled Arabic font and text shaping |
| Bundled Arabic font | Not started | design asks to confirm availability first; the system font is used |
| Release signing | Deferred by product decision | the shared debug key is used |
| LICENSE file | Not started | the README refers to it; the owner decides the license |
| Committed pubspec.lock and exact share_plus pin | Not started | needs Flutter or a CI helper to resolve versions |

## Verification log
| Build | Commit | CI | Device |
|---|---|---|---|
| 4 | closing docs + merge | green (docs only) | not applicable |
| 3 | 5520f0b | green: analyze, all tests, release APK 55 MB, package com.moamen.addady (Phase 2: notifications, tariff, language, export) | owner installed it and approved overall (2026-11-16); item-level results not reported |
| 3 | e9fb982, a77ea47, 57dc072 | green (earlier Phase 2 commits) | not device-tested separately |
| 2 | 0e89188 / b2d6f57 | green on main (Phase 1) | obsolete package com.moamen.eaddady |
| 1 | 39fbc54 | green: analyze, 28 tests, release APK 53 MB, package com.moamen.eaddady | owner installed it, followed the suggested test list, reported everything functional and the design close, except card/widget sizes vs the design |
