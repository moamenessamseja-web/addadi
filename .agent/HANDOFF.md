# HANDOFF.md — 60-second start

1. Read `README.md` → `ENGINEERING_RULES.md` → `IMPLEMENTATION_STATE.md`.
2. **Test target now:** the APK artifact `android-apk` of the latest green run of the PR from branch `agent/phase2-notifications` (applicationId `com.moamen.addady`). The Phase 1 APK (`com.moamen.eaddady`, main) is obsolete: the owner removes it. Nothing of Phase 2 is owner-confirmed yet. Last owner-confirmed: nothing yet. Distrust: nothing yet.
3. Owner's current task list: (1) green build of the first working version — in progress; (2) owner installs and reports.
4. Do not: merge before the owner's OK · change the applicationId after the owner installed an APK · add external services or accounts (the product is offline by design) · invent behaviours listed as open decisions (DECISIONS) without saying so · claim unverified things.
5. Environment notes: no Flutter SDK in the authoring sandbox; the pure-Dart domain can be run with a plain Dart SDK, everything else is verified by CI. Token never in files.
