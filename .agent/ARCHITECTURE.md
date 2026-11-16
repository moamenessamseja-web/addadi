# ARCHITECTURE.md — current architecture (2026-11-15)

## Layers
- Entry/startup: `lib/main.dart` opens local storage, loads the store, runs `EaddadyApp`. If storage cannot open, an Arabic error screen is shown instead of a blank one.
- Domain (pure Dart, no Flutter): `lib/domain/` — `models.dart` (Meter, Reading), `consumption.dart` (segments, periods, spike analysis, entry validation), `format.dart` (number parsing/formatting, dates), `app_data.dart` (the persisted JSON document).
- Data: `lib/data/` — `storage.dart` (KeyValueStorage, PrefsStorage, MemoryStorage), `app_store.dart` (ChangeNotifier; writes to storage first, notifies after).
- UI: `lib/ui/` — tokens (design foundation colors/spacing/radii, light + dark), theme, shared widgets (`NumericText` = left-to-right numeric run), `shell.dart` (app bar with alert bell, drawer, 3-tab bottom navigation), `home_screen.dart`, `add_reading_screen.dart`, `analytics_screen.dart`, `drawer.dart` (settings, meter management), `add_meter_sheet.dart`, `chart.dart` (local CustomPaint line chart), `strings.dart` (all Arabic text).
- Notifications: pure logic in `lib/domain/notifications.dart` (backend interface, coordinator, ids, due moment, spike de-duplication); the Android plugin is `lib/data/plugin_notifications.dart`; `AppStore` calls the coordinator after a reading is saved, on meter delete, on toggle and at startup. Tests use a fake backend.
- Config/CI: `.github/workflows/build-apk.yml` calls the central gateway workflow (pinned tag) and a PR-only method check. `android/` is NOT committed; the workflow generates it and `tool/ci_android.sh` sets the Arabic launcher label.

## Key data flow
```
 Add reading UI -> AppStore.addReading -> validateReading (domain) -> storage.write(JSON) -> notifyListeners -> Home / Analytics / bell rebuild from analyzeMeter
```

## Facts that bite
- A reset/replacement reading opens a new segment; nothing is calculated across it (domain tests cover this).
- Only the pure-Dart domain is unit-tested without a device; the Flutter UI is verified by CI (analyze + widget tests + build) and by the owner's device.

## Known limits (honest)
- No photos, notifications, export, tariff estimate or language switch yet (see implementation.md).
- No pubspec.lock is committed (cannot be created without Flutter); dependency versions float within `^` ranges until one is committed.
