# HANDOFF.md — 60-second start (project paused 2026-11-16)

1. Read `AGENTS.md` (repo root) → the central gateway `https://github.com/moamenessamseja-web/Flutter-Android-Build` (`.agent/README.md`, `.agent/RUN.md`) → this folder: `BRIEF.md`, `IMPLEMENTATION_STATE.md`, `implementation.md`, `DECISIONS.md`, `LESSONS.md`.
2. **State:** Phase 1 and Phase 2 are finished and merged into `main`; the owner installed the APK of commit `5520f0b` and approved it overall. Nothing is in progress.
3. **Trust:** the code compiles, analyzes clean and passes its tests in CI at 5520f0b. **Distrust until the owner reports:** real notification delivery and the reminder after a phone reboot (Android 13+ permission dialog), the share sheet / CSV in a spreadsheet app, the English layout, the edit-meter form and cost estimate with a real tariff, R8-shrunk release behaviour on the owner's phone.
4. **Owner device test list for Phase 2** (the owner removes the old `eaddady` app first; the current one is `com.moamen.addady`):
   - Drawer: notifications switch on (Android asks permission); save three rising readings (for example 100, 150, 220): a phone notification must appear; reboot the phone and check nothing breaks.
   - Drawer → manage meters → open a meter → set a tariff (tiers, fixed fee, currency) → Analytics shows the cost estimate labelled as an estimate.
   - Drawer → language Arabic/English: layout flips, numbers stay Latin; export CSV opens the share sheet, open the file in a spreadsheet app and check the Arabic.
   - If the screen is black at launch: earlier problem with `shared_preferences_android` 2.5.0 on this phone (manager-assistant-ready); the fix there was a `dependency_overrides` pin to 2.4.28.
5. **How to resume work** (the owner works from a phone with free GitHub; the gateway recipe is `.agent/RUN.md` in the gateway):
   - Work on a branch `agent/<task>`, open a PR; the caller workflow `.github/workflows/build-apk.yml` builds through the gateway and a PR-only method check enforces updating `IMPLEMENTATION_STATE.md`, `HANDOFF.md` and `CHANGELOG.md` in every PR.
   - Wait with `gh_ci.sh wait <branch>`; read the result with `gh_ci.sh result <branch>` (the `APK ready` annotation carries commit, package, size, signer, analyze/tests status). Tell the owner the commit number; the owner downloads the APK from the run page (Artifacts → `android-apk`; artifacts expire after 14 days: rebuild with "Run workflow" on `main`).
   - Pure-Dart logic can be tested without Flutter, see `LESSONS.md` (technique L7). Everything else is verified by CI.
   - Do not merge before the owner says so; the owner merges or asks explicitly.
6. **Do not:** change the applicationId after the owner installed an APK · add network services, accounts or analytics (the product is offline by design) · invent behaviours listed as open decisions without saying so · claim device verification that did not happen · put a token anywhere in the repo.
7. **Next work, in order:** see "Open items" in `IMPLEMENTATION_STATE.md`.
