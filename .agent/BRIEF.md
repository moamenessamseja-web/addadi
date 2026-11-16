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

## 2026-11-16 — after the first APK (owner tested everything on the phone)
> تمام نزلت ال apk مانيوال ... جربت كل شئ كما اقترحت وكله تمام وظيفيا وحتي التصميم مقارب ل Eaddady_Design_Foundation_v0 باستثناء حجم الكروت الويدجت (وارد ان تكون مهارات التصميم القديمة والجديدة تحتاج مراجعة.. سيبك منها لها محادثات اخري بالفعل)
> المطلوب منك ان تكمل الخطوات ابتداءً من الاشعارات ثم باقي عناصر القائمة الجانبية، تغيير اسم الحزمة الي addady.. سأمسح ال apk من فوني ونبدأ من جديد.. انا لم ادمج اي فرع علي ال main

**Reading:** Phase 1 accepted functionally. Phase 2 order: (1) local notifications, (2) the remaining drawer items (meter configuration + local tariff, language, export), (3) package name `addady`. The owner deletes the old APK and starts fresh. Card/widget size differs from the design (design skills are being reviewed elsewhere; out of scope here). The owner has NOT merged anything: do not merge; leave the PR for the owner.
