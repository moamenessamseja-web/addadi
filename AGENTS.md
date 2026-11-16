# Agent instructions

Before any work in this repository, use the central engineering gateway:
1. `git clone --depth 1 https://github.com/moamenessamseja-web/Flutter-Android-Build.git /tmp/gateway`
2. Read `/tmp/gateway/.agent/README.md` and follow it (it points to the Engineering in Charge skill, which you must read first), then `/tmp/gateway/.agent/RUN.md` for the delivery recipe.
3. This repository's own memory is in `.agent/` (create it with the gateway's `init_agent.py` if missing). Read it after the gateway.
4. Never assume this project has the same architecture as another one; inspect it first.

## If your harness has no bash/git
If your harness has no bash/git, follow `.agent/HTTP_ONLY.md` instead.
No git? Fetch the gateway files directly (no token, public repo):
`https://raw.githubusercontent.com/moamenessamseja-web/Flutter-Android-Build/main/<path>`
Start with `.agent/README.md`, then `.agent/ACCESS.md`, then `.agent/HTTP_ONLY.md`.
You cannot run the gate scripts in that mode; HTTP_ONLY.md defines the API equivalents.

## Facts to respect in every target repository
- `.github/workflows/build-apk.yml` calls the gateway's reusable workflow. Keep the Flutter version pinned.
- Commit `pubspec.lock`; the pub cache key uses its hash.
- The applicationId is fixed by the pubspec `name` (+ `--org`). Decide it BEFORE the first APK is installed on the owner's phone; it cannot change afterwards without uninstalling.
- Work on `agent/<task>`, open a PR with the agent's own PAT (a PR opened with `GITHUB_TOKEN` does not start CI). Merge to `main` only after the owner device-tested.

## Facts of this repository (Ɛaddady / عَدّادي)
- Product and rules: `README.md` (what the app is) and `Eaddady_Design_Foundation_v0.1.md` (design foundation; section 13 lists open decisions that must not be invented silently, see `.agent/DECISIONS.md`).
- The app is 100% offline and private: no accounts, no cloud, no analytics. Do not add network services.
- `android/` is NOT committed: the central workflow generates it on every build (`flutter create --platforms=android --project-name eaddady --org com.moamen`), then `tool/ci_android.sh` sets the Arabic launcher label. Native changes (permissions, receivers, icon) go through that script (see the gateway skill reference android-ci-injection.md) or by committing `android/`.
- applicationId: `com.moamen.eaddady`. It cannot change after the owner installed an APK.
- Flutter is pinned in `.github/workflows/build-apk.yml` (3.47.9). `pubspec.lock` cannot be created without Flutter; keep dependency versions deliberate.
- Pure-Dart domain logic lives in `lib/domain/` (no Flutter imports) so it can be tested without a device; keep it that way.
- `.agent/HTTP_ONLY.md` is a copy of the gateway file of the same name.
