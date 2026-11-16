# BRIEF.md — what the owner wants (their words first)

## 2026-11-15 — first real project through the gateway
> repo addadi (2 files: README, DESIGN for this app), name Ɛaddady (عَدّادي), now handle it from now to give me the approval green build

(Verbatim, the owner's wording; the owner asked in English/Arabic mix. The two files are `README.md` and `Eaddady_Design_Foundation_v0.1.md`.)

**Engineering reading (mine, not the owner's):**
- Goal: a first installable Android APK of the app described in README + design foundation; the owner installs it by hand from the GitHub run page and replies with the commit number and feedback.
- Hard constraints (stated in the README/design): 100% offline and private, no accounts, no cloud; Arabic RTL with numeric values left-to-right; compare a meter only with itself; never invent behaviours listed as open decisions in design section 13 without saying so.
- Priorities in order: 1) a green build of a real, working core (meters, readings, spike logic, local storage); 2) honest reporting of what exists and what does not; 3) later phases (photos, notifications, export, tariff).
- Explicitly NOT now: photo evidence, local notifications, CSV/PDF export, tariff/cost estimate, language switch, release signing.

## Owner profile and working style
- Language / tone: Arabic (Egyptian), writes technical terms in English.
- Technical level: not a programmer; explain consequential decisions in plain words.
- Pet peeves: false "done" claims; wants the commit number with every green build.
