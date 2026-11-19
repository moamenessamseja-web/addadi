# ARCHITECTURE.md — current architecture (2026-11-16)

## Repository map
```
AGENTS.md                         agent entry point -> central gateway -> .agent/
README.md                         the owner's product description (do not rewrite without the owner)
Eaddady_Design_Foundation_v0.1.md the owner's design foundation (tokens, screens, open decisions in section 13)
pubspec.yaml                      name `addady`; flutter_local_notifications 17.2.4 + timezone 0.9.4 (pinned), share_plus ^11.0.0, shared_preferences ^2.3.0
.github/workflows/build-apk.yml   caller: builds through gateway Flutter-Android-Build@v1.0.0 (Flutter 3.47.9, release, --org com.moamen) + PR-only method check
tool/ci_android.sh                runs in CI after `flutter create` (android/ is NOT committed): Arabic launcher label, notification permissions + receivers, desugaring, R8 rules
.agent/                           project memory (see .agent/README.md); archive/ holds superseded docs
lib/main.dart                     start: storage, notification backend, store, sync reminders; error screen if storage cannot open
lib/app.dart                      MaterialApp: locale from the store (ar/en), light/dark theme
lib/domain/   (pure Dart, no Flutter imports; unit-tested without a device)
  models.dart        Meter (with optional Tariff), Reading (isReset), UtilityType, language-aware labels
  consumption.dart   segments split at resets, periods, spike analysis (needs >= 3 readings in the segment), entry validation
  tariff.dart        progressive tiers, fixed fee, cost estimate, validation
  notifications.dart backend interface, coordinator, stable ids, due moment, spike de-duplication
  csv_export.dart    CSV builder (BOM, quoting, formula neutralising) and the export sink interface
  app_data.dart      the one persisted JSON document (meters, readings, settings, language, alert de-dup)
  format.dart        number parsing (Arabic-Indic digits) and formatting (Latin), dates
  language.dart      the single global language code
lib/data/
  app_store.dart     ChangeNotifier; writes storage first, notifies after; calls notifications and export; sets the language
  storage.dart       KeyValueStorage, PrefsStorage (shared_preferences), MemoryStorage (tests)
  plugin_notifications.dart  flutter_local_notifications backend (inexact alarms)
  plugin_export.dart share_plus backend (temp file + share sheet)
lib/ui/
  strings.dart       ONE bilingual table (key -> [Arabic, English]) + getters; tested
  tokens.dart theme.dart widgets.dart chart.dart notification_texts.dart
  shell.dart home_screen.dart add_reading_screen.dart analytics_screen.dart drawer.dart edit_meter_page.dart add_meter_sheet.dart
test/                             76 tests: 61 pure-Dart (also run locally) + 15 that need Flutter (run in CI only); fake_backend.dart is shared
```

## Key data flows
```
 Add reading UI -> AppStore.addReading -> validateReading (domain) -> storage.write(JSON) -> notifyListeners
                -> notifications: re-arm due reminders, spike alert once per latest reading -> UI rebuilds from analyzeMeter
 Drawer actions -> AppStore (setNotificationsEnabled / setLanguage / updateMeter / exportCsv ...) -> same commit-then-notify path
```

## Facts that bite
- A reset/replacement reading opens a new segment; nothing is calculated across it (tests cover it).
- Android native setup is generated: `android/` is not in the repository; anything native goes through `tool/ci_android.sh` (or commit `android/` once).
- Release builds are shrunk by R8; `tool/ci_android.sh` writes the keep rules. Notifications and shared_preferences were only exercised on a device in Phase 1 (shared_preferences) and not yet for notifications.
- Language is a global read at call time: UI, `Meter.title`, notification texts follow it. `AppStore._commit` sets it before notifying listeners.
- Strings are getters (not const): widgets that use them cannot be `const`.

## Known limits (honest)
No photos, no PDF export, system font only, shared debug signing key, no committed `pubspec.lock`, date/time pickers may show Arabic-Indic digits (unchecked), notification delivery and reboot persistence unchecked on a device.
