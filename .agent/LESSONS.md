# LESSONS.md — symptom → real cause → what to do (evidence-based)

Part 1 is about this project. Part 2 is the backlog for `Flutter-App-Template` and the gateway, collected from the whole parent conversation (2026-11-06 .. 2026-11-16).

# Part 1 — this project

## L1. A pull request was merged and nobody reported doing it
- Cause: `PR #1` was merged through the API at 05:09:44Z by an actor authenticated as the owner's account with a custom merge title; the owner said they did not merge it and the authoring agent had not either. So another agent or session uses the same token (the token was pasted in chat several times).
- Next time: never assume who merged; check `merged_by` and the events; tell the owner; rotate the token (fine-grained, limited to the needed repositories).

## L2. A push to a branch whose PR was already merged built nothing
- Cause: no open PR means no `pull_request` run; the branch tip was outside `main`.
- Next time: check `gh_ci.sh wait` finding no run for your commit (it says `waiting-for-run`); look at the PR state and branch head before waiting longer; open a new PR.

## L3. Plugin versions that are proven on the owner's phone
- `flutter_local_notifications 17.2.4` + `timezone 0.9.4`: built in CI and delivered notifications on the owner's phone in manager-assistant-ready (commit d2a17ef); newer majors change the API. `share_plus ^11.0.0` compiled in CI on the first try but was never run on the phone.
- `shared_preferences_android` 2.5.0 caused a black screen on the owner's phone in manager-assistant-ready (fix: `dependency_overrides` pin to 2.4.28); this project did not hit it with the unpinned resolution. If it appears, apply the same pin.

## L4. Native Android changes without committing `android/`
- Pattern: `tool/ci_android.sh` runs through the gateway input `pre_build_command` after the scaffold: label, permissions, receivers, desugaring, R8 keep rules. It is idempotent and verifies its own result, and was dry-run on a mock manifest/gradle file before the first CI run.
- Next time: dry-run such scripts locally first (CI feedback costs minutes).

## L5. `flutter create` adds files the app did not have
- It generates `analysis_options.yaml` (needs flutter_lints) and a default `test/widget_test.dart` (refers to `MyApp`); the central workflow now removes them when the app had none. Directory name is used as the project name unless `--project-name` is given (also fixed centrally).

## L6. Notification design that avoids the old failures (from d2a17ef and tested here)
- Schedule at an absolute moment; re-arm on every save, setting change and app start; never schedule the past; inexact alarms need no special permission; one spike alert per meter per latest reading (persisted); preference and OS permission are separate; a notification failure must never fail a saved reading; the in-app bell works without any OS permission.

## L7. Testing pure-Dart logic without a Flutter SDK (authoring sandbox without pub.dev / Flutter storage)
- Keep `lib/domain/` free of Flutter imports. Fetch a Dart SDK from conda-forge (`conda.anaconda.org/conda-forge/linux-64/dart-sdk-*.conda`, a zip containing a zstd tar; unpack with python `zstandard`), `dart run` works but `dart analyze` crashes (analyzer snapshots stripped). Provide a tiny stand-in for `package:flutter_test` (test/group/expect/equals/closeTo/isNull/isTrue/isFalse, async-aware) through a hand-written `.dart_tool/package_config.json` and run a small runner file that imports the test files. 61 tests ran this way before every push; the Flutter-dependent ones run only in CI.

## L8. Adding a second language late
- All UI strings were `const` Arabic. The cure: one table `key -> [Arabic, English]` with getters (not const), a tested rule that every key has both languages, and an automated transformation that removes `const` from every widget expression that contains `S.*` (a bracket-matching script that understands nested strings). It compiled first time. Next time start with getters from day one.

## L9. APIs that were avoided on purpose because CI feedback is slow and Flutter changes fast
- No component themes in `ThemeData` (`CardTheme`/`AppBarTheme`/`InputDecorationTheme` changed types across versions); `ColorScheme(...)` with only the required fields; `Color.withValues` instead of `withOpacity`; no `DropdownButtonFormField(value:)`; no `MaterialStateProperty`; no `Radio`; `ChoiceChip`/`SegmentedButton`/`SwitchListTile` without colour overrides.

## L10. Things not yet understood or unchecked
- Arabic-Indic digits in the Material date/time pickers (locale `ar`); notification delivery/timing and reboot persistence; R8-shrunk release behaviour on the phone; whether card sizes differ from the design because of tokens or widgets (the owner reported the difference).

# Part 2 — backlog for `Flutter-App-Template` and the gateway (`Flutter-Android-Build`)

## Template (what a new app should start with)
1. Layers from day one: `lib/domain` (pure Dart, unit-tested without a device), `lib/data` (store + injectable backends behind interfaces), `lib/ui`; a `test/` folder with a shared fake-backend pattern.
2. Strings as getters over one bilingual table (even if only Arabic at first), with the table test; no `const Text(S.x)`.
3. `tool/ci_android.sh` with optional blocks (label, notifications, other plugins), each verifying its own result; document the dry-run trick.
4. `build-apk.yml` caller already pinned to a gateway tag and with the PR-only method job; add a comment on `pre_build_command`.
5. Decide the package name and applicationId with the owner BEFORE the first build; make the placeholder name obvious (`app_template`) and the rename a documented step (pubspec, imports, test, label, AGENTS.md).
6. `AGENTS.md` and `.agent/` bootstrap: include the `HTTP_ONLY.md` index line automatically; fix the contradiction "commit pubspec.lock" (it cannot be produced without Flutter).
7. A `pubspec.lock` strategy: print the resolved direct dependencies in the build annotation or upload `pubspec.lock` with the artifact, or a manual workflow that opens a PR committing it.
8. Design: tokens/theme from the design skill; owner feedback says card sizes differ from the design foundation.
9. Proven plugin pins list (L3) and the black-screen pin recipe.

## Gateway
1. Keep one copy of the gate/CI scripts (done in v1.0.0); consider a `result` hint when a push built nothing (L2).
2. Pin handling: gateway tags (`v1.0.0`); upgrade process in its README; a canary workflow exists.
3. The `android_scaffold: never` and invalid-package-name failure paths are verified manually, not automated.
4. Token handling: document fine-grained token scopes and that a token seen in chat must be rotated; consider a read-only mode for agents that only need to build.
5. Ideas not done: a helper that runs the local pure-Dart test technique (L7) from the gateway; a check that warns when a PR is closed but the branch received new commits.
