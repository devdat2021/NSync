# AI IDE Agent Instructions: College Attendance Tracker MVP

## 📌 Project Overview & Intent
We are building a completely client-side, local-first, high-contrast dark-mode mobile application using **Flutter**. The app automatically scrapes attendance statistics from a student portal, caches the snapshot payload locally, and provides an interactive sandbox simulator to test "what-if" bunking scenarios.

### Core Architectural Guardrails (Strict)
1. **No Backend Database/Server:** Do not create any Firebase, Node.js, Python, or external server infrastructures. The architecture must remain strictly Client-to-Portal-Server.
2. **Absolute Privacy:** Do not store sensitive login details in plain-text storage files or databases. Use hardware-backed secure storage.
3. **Immutability of Official Data:** The interactive detailed view simulator must never overwrite or permanently alter the actual numbers fetched from the server. It must only manipulate local temporary state variables.

---

## 🛠️ Required Stack & Dependencies
Ensure the following packages are integrated into `pubspec.yaml`:
* `dio` (For standard cookie-managed HTTP transactions)
* `dio_cookie_manager` (To auto-intercept and attach session identifiers)
* `cookie_jar` (In-memory handling of volatile cookies)
* `flutter_secure_storage` (Hardware-isolated vault encryption for credentials)
* `shared_preferences` (Lightweight local text string snapshot cache)
* `intl` (For date formatting utilities)

---

## 📂 Target File Architecture (`lib/`)
Implement code strictly across this organized layout structure:

lib/
├── main.dart                       # App bootstrapper; global dark theme configuration
├── core/
│   ├── constants/
│   │   └── app_colors.dart         # Hex design tokens (Midnight black, vivid emerald, deep rose)
│   └── security/
│       └── credential_vault.dart   # FlutterSecureStorage wrapper for username/password
├── data/
│   ├── models/
│   │   └── course_attendance.dart  # Data object holding subject metrics and simulation math
│   ├── providers/
│   │   ├── portal_scraper.dart     # Two-step Dio cookie login & data parsing sequence
│   │   └── attendance_cache.dart   # SharedPreferences reader/writer snapshot utility
│   └── repositories/
│       └── attendance_repository.dart # Directs cache fallbacks and background network refreshes
└── presentation/                   # Presentation Layer (Separate Scaffolds & Views)
    ├── screens/
    │   ├── splash_gatekeeper.dart  # Routes user based on saved login presence
    │   ├── setup_login_screen.dart # User credential input page (first-time launch)
    │   ├── dashboard_screen.dart   # Main view matching your uploaded high-contrast UI
    │   └── detailed_calc_screen.dart # Separate Scaffold deep-dive calculator view
    └── widgets/
        ├── overall_stats_card.dart # The large top component (74.2% summary layout)
        └── attendance_card_item.dart # The dynamic course card component with pill badges
---

## 🏎️ Day-by-Day Implementation Roadmap

### 🗓️ Day 1-2: Network & Data Infrastructure (The Scraper Engine)
* **Goal:** Replicate the working two-step session-cookie cURL workflow natively in Dart.
* **CURL Reference Sequence:**
  1. `curl -c c.txt -d "regno=USER&passwd=PASS" https://studentportal.universitysolutions.in/signin.php`
  2. `curl -b c.txt --compressed "https://studentportal.universitysolutions.in/app.php?a=viewAttendanceDetsummary&univcode=049&date=YYYY-MM-DD"`
* **Action:** Build `portal_scraper.dart` using `Dio` and `DioCookieManager`. Parse incoming string metrics from the nested `data` key block dynamically into individual instances of `CourseAttendance`.

### 🗓️ Day 3: Local Storage & Snapshot Caching
* **Goal:** Create instantaneous app loads using offline snapshots and secure credential retention.
* **Action:** 1. Implement `credential_vault.dart` to save/retrieve passwords through hardware encrypted lanes.
  2. Implement `attendance_cache.dart` using `shared_preferences` to write/read raw JSON payload snapshots.
  3. Wire up `attendance_repository.dart` to yield the cached snapshot instantly on app launch while firing off the background scraping updater.

### 🗓️ Day 4-5: High-Contrast Dashboard & Core Math
* **Goal:** Implement the primary dark layout viewport and calculation metrics.
* **The Math Specs (75% Baseline Threshold):**
  * `Percentage = (Attended / Conducted) * 100`
  * If `Percentage >= 75%`: Increment simulated total classes forward while keeping attended classes static to locate the maximum safe bunks balance count.
  * If `Percentage < 75%`: Increment both simulated total and attended numbers simultaneously to calculate the mandatory streak recovery count.
* **Action:** Build out `dashboard_screen.dart`. Render dynamic individual tiles detailing subject titles, ratio statistics, custom progress bars, and status pill badges matching the colors (Emerald Green for safe, Rose Red for deficit). Include a `RefreshIndicator` wrapper to let users pull-to-refresh manually.

### 🗓️ Day 6: Interactive Screen Simulation (No-Write Sandbox)
* **Goal:** Build the separate detailed screen pushed on card selection that acts as a safe calculation sandbox.
* **Action:** Create `detailed_calc_screen.dart` as a `StatefulWidget`. Initialize state counters with the course metrics. Add interactive addition and subtraction increment rows. Wrap inputs with defensive conditional limits (e.g., attended classes can never exceed total classes held). Use `setState()` to update the big percentage ticker and status banners in real-time.

### 🗓️ Day 7: Release Verification
* **Goal:** Build and compile a localized distribution version for physical user testing.
* **Action:** Review exception handling blocks across the network parser. Ensure all JSON decoding processes fail gracefully into the offline storage cache if connection anomalies occur. Run compilation tests (`flutter run --release`).