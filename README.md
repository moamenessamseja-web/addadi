# Ɛaddady (عَدّادي)

> Know your consumption before the bill arrives.

**Ɛaddady** is a private, offline-first personal utility tracking tool designed to monitor utility meters (Electricity, Water, Gas), document readings with photo evidence, and catch abnormal consumption spikes early—before the official utility bill arrives.

*Note: Ɛaddady is not a bill-payment portal or a bloated accounting dashboard. It is a focused, intentional micro-tool designed to give users absolute control and peace of mind over their consumption.*

---

## 🌟 Key Differentiators & Philosophy

* **100% Offline & Private:** All data, photos, and charts stay locally on your device. No cloud sync, no accounts, and zero connection to utility companies.
* **The "Spike Alert" Heartbeat:** The core value proposition isn't just a logbook; it’s proactive defense. If current consumption exceeds the previous month by a threshold (e.g., +30%), Ɛaddady flags it immediately.
* **Photo-Backed Proof:** Every reading can be paired with a local photo snapshot, acting as irrefutable evidence against billing disputes.

---

## 📱 MVP Architecture & Screen Flow

The application is structured around a streamlined, lightweight 3-screen core experience backed by a comprehensive side drawer and a live status indicator.

### 1. The Meters Screen (Home)
* **Top Notification Bell:** Displays a live alert indicator (🔴) when an abnormal consumption spike or pending reading is detected. Tapping it opens a quick-glance notification drawer.
* **Consumption Overview:** Clean summary cards displaying current meter statuses (Electricity, Water, Gas) categorized by property/location (Apartment, Villa, Shop, Pool, etc.).
* **Card Details:** Shows the latest reading, exact date, and clear visual indicators for meters requiring new readings.

### 2. Add Reading Screen
* **Meter Selection:** Choose the target utility meter.
* **Capture & Input:** Snap a photo of the physical meter dial + manual numeric entry + timestamp.
* **Meter Reset / Replacement Tag:** Integrated toggle/checkbox to flag hardware changes or resets. This prevents false spike alarms caused by hardware rollbacks while securely preserving historical archives.
* **Instant Calculation:** Automatically computes consumption differences against the previous historical record.

### 3. Analytics Screen
* **Consumption Trend Curves:** Simple, clean local monthly consumption trend charts.
* **Month-over-Month Comparison:** Precise percentage changes and variance tracking.
* **Daily Burn Rate:** A built-in pace indicator showing the average daily consumption rate to help users monitor pacing throughout the billing cycle.
* **Local Cost Estimator:** Optional local tariff input per meter that translates consumption differences into estimated monetary values (e.g., *~150 EGP expected increase*).

---

## 🗂️ Side Drawer & General Settings
Accessible globally via the navigation menu to manage local preferences and data:
* **Meter & Property Management:** Add, configure, or remove meters and set custom local pricing tiers for cost estimations.
* **Alert Thresholds:** Customize spike detection limits (e.g., alert at +30% growth) and toggle local notification preferences.
* **Preferences:** Language selection and theme switching (Dark/Light mode).
* **Local CSV/PDF Export:** Offline tool enabling users to export logs and photo references for personal backups or sharing when needed.

---

## ⚙️ Functional Rules & Edge Cases

To maintain data integrity without cluttering the interface, Ɛaddady enforces strict internal logic:
* **Self-Comparison Only:** Consumption is compared exclusively against the same meter's historical timeline—never across different meters.
* **Data Maturity:** Spike alerts require a minimum of at least two valid historical readings to establish baseline trends.
* **Anomaly Safeguards:** 
  * Rejects negative consumption values as invalid.
  * Handles meter resets, replacements, or capacity overflows seamlessly via the reset tag.
* **Data Integrity:** Photos, timestamps, and numeric readings remain permanently locked together within individual record logs.

---

## 🛠️ Technology Stack (MVP)
* **Local Storage:** Secure local database for text logs and image assets.
* **Charting:** Lightweight offline rendering engine for consumption curves.
* **Notifications:** Native local notification scheduler for spike warnings.

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.
