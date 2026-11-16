# Changelog (completed work only — never plans)

## 2026-11-15
- Phase 1 app created on branch `agent/phase1-shell`: domain logic with 25 unit tests (passed locally), local storage, Home / Add reading / Analytics screens, drawer, alert bell, light and dark theme. Build 1 (commit 39fbc54): CI green — analyze clean, 28 tests passed, release APK 53 MB, package com.moamen.eaddady, signed with the shared debug key. Not device-tested.
- Added AGENTS.md (agent entry point pointing to the central gateway).
- Recorded the earlier notifications solution (manager-assistant-ready commit d2a17ef) in DECISIONS.md for Phase 2.
- Owner merged Phase 1 into main (0e89188); main build is CI-green. State docs updated accordingly.

## 2026-11-16 (Phase 2, branch agent/phase2-notifications)
- Package renamed to addady (applicationId com.moamen.addady).
- Local notifications: spike alert once per latest reading, 30-day reading reminder, preference switch with OS-permission handling; native setup injected by tool/ci_android.sh. CI result: see the pull request.
