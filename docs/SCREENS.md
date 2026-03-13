# SCREENS.md
# ClassPulse — Screen Specifications

> **AI Instruction:** This file defines every screen's layout, components, state, and service calls.
> Build screens exactly as specified. Do NOT add extra screens or navigation flows.
> Every screen uses `AppColors`, `AppTextStyles`, `AppSpacing`, and `AppRadius` from THEME.md.
> Never write business logic or service calls inside widget `build()` methods.

---

## Screen 1: SplashScreen

**Route:** `/splash`  
**File:** `lib/features/splash/splash_screen.dart`

### Purpose
Brand entry point. Displays logo and app name for 2 seconds, then auto-navigates to Home.

### Layout
```
┌───────────────────────────└
│                           │
│                           │
│      [ Logo Icon ]        │  ← fade-in animation
│       ClassPulse          │  ← AppTextStyles.displayLarge (white)
│   Smart Class Check-in    │  ← AppTextStyles.bodyMedium (white 70%)
│                           │
│                           │
└───────────────────────────┘
```

### Specs
- Background: `AppColors.primary` (`#6D4AFF`)
- Logo: `Icons.school_rounded` at 72px, color white
- Title: "ClassPulse" — `AppTextStyles.displayLarge` in white
- Tagline: "Smart Class Check-in" — `AppTextStyles.bodyMedium` in white with 70% opacity
- Animation: `FadeTransition` on entire column, duration 600ms
- Auto-navigate: `Future.delayed(Duration(seconds: 2))` → `context.go(AppRoutes.home.path)`

### State
- No Provider/state needed. Pure `StatefulWidget` with `initState` timer.

### Components Used
- No reusable atoms — self-contained screen.

---

## Screen 2: HomeScreen

**Route:** `/home`  
**File:** `lib/features/home/home_screen.dart`

### Purpose
Main hub. Shows current session status, action button, and session history list.

### Layout
```
┌───────────────────────────└
│  AppBar: "ClassPulse"      │  ← AppTextStyles.titleLarge, no back button
├───────────────────────────┤
│                           │
│  ┌───────────────────└  │  ← StatusCard (large card)
│  │  🟣 Ready to Check In │  │
│  │  Today, 13 Mar 2026   │  │
│  └───────────────────┘  │
│                           │
│  [✔ Check In ]            │  ← Primary button (visible based on status)
│                           │
│  ─── Recent Sessions ───  │  ← Section label
│  [ Session History List ] │  ← SessionHistoryItem atoms
│                           │
└───────────────────────────┘
```

### Status Card States

| Status | Icon | Title | Card Background |
|--------|------|-------|-----------------|
| `null` (no session) | `🟣` | "Ready to Check In" | `AppColors.surface` |
| `checkedIn` | `⏳` | "Class In Progress" | `AppColors.primaryLight` |
| `completed` | `✅` | "Class Completed!" | `Color(0xFFE8F5E9)` (light green) |

### Action Button Logic

| Status | Button Shown | Label | Navigates To |
|--------|-------------|-------|-------------|
| `null` | Check In button | "Check In" | `/checkin` |
| `checkedIn` | Finish button | "Finish Class" | `/finish` |
| `completed` | No button | — | — |

> **AI Instruction:** Use a single conditional widget — do NOT render both buttons and toggle `enabled`. Only render the relevant button.

### Session History List
- Shows all past `CheckInRecord` where `status == completed`
- Each item: `SessionHistoryItem` atom
- Empty state: centered text "No sessions yet" in `AppTextStyles.bodyMedium`
- Loaded from `CheckInService.getAllRecords()`

### State (Provider)
- Reads: `CheckInNotifier` → `currentRecord` (nullable `CheckInRecord`)
- Reads: `CheckInNotifier` → `sessionHistory` (List<CheckInRecord>)
- Calls: `CheckInService.getAllRecords()` on `initState`

### Atoms Used
- `StatusCard` — displays session state
- `SessionHistoryItem` — one row per past session

---

## Screen 3: CheckInScreen

**Route:** `/checkin`  
**File:** `lib/features/checkin/check_in_screen.dart`

### Purpose
Captures GPS location, QR scan, and pre-class reflection. Creates a new `CheckInRecord`.

### Layout
```
┌───────────────────────────└
│  AppBar: "Check In"        │  ← back button disabled
├───────────────────────────┤
│  ── Step 1: Location ──   │
│  [ 📍 Get My Location ]    │  ← Outlined button → LocationService
│  "Lat: 20.04 | Lng: 99.89" │  ← Shows after capture (bodyMedium)
│                           │
│  ── Step 2: QR Code ───   │
│  [ 📷 Scan QR Code ]      │  ← Outlined button → opens QR scanner
│  "Session: MAD-W07"       │  ← Shows sessionId after scan
│                           │
│  ── Step 3: Reflection ──  │
│  [ Previous Topic input ]  │  ← TextFormField
│  [ Expected Topic input ]  │  ← TextFormField
│  [ Mood Selector ]         │  ← MoodSelector atom (5 tiles)
│                           │
│  [ Submit Check In ]       │  ← Primary button (disabled until all steps done)
└───────────────────────────┘
```

### Step Completion Rules
- Submit button is **disabled** until: GPS captured AND QR scanned AND both text fields filled AND mood selected
- GPS status shows inline below the button: loading spinner → coordinates text
- QR status shows inline: "Tap to scan" → "Session ID: [value] ✓"

### On Submit
1. Creates `CheckInRecord` with all captured data
2. Calls `CheckInService.saveCheckIn(record)`
3. Updates `CheckInNotifier.currentRecord`
4. Navigates: `context.go(AppRoutes.home.path)`

### State (Provider)
- Local: `_gpsLocation` (GpsLocation?), `_sessionId` (String?), `_moodScore` (int?)
- Local: `_formKey` (GlobalKey<FormState>)
- Writes to: `CheckInNotifier`

### Atoms Used
- `StepSectionLabel` — "Step 1: Location" headers
- `MoodSelector` — 5 emoji mood tiles
- `StatusIndicator` — inline GPS/QR capture feedback

---

## Screen 4: FinishClassScreen

**Route:** `/finish`  
**File:** `lib/features/checkout/finish_class_screen.dart`

### Purpose
Captures QR re-scan + GPS + post-class reflection. Updates existing `CheckInRecord` to `completed`.

### Layout
```
┌───────────────────────────└
│  AppBar: "Finish Class"    │  ← back button disabled
├───────────────────────────┤
│  ── Step 1: QR Code ───   │
│  [ 📷 Scan QR Code ]      │  ← Must match check-in sessionId
│  "Session: MAD-W07 ✓"    │  ← Confirmed after scan
│                           │
│  ── Step 2: Location ──   │
│  [ 📍 Get My Location ]    │  ← Outlined button → LocationService
│  "Lat: 20.04 | Lng: 99.89" │
│                           │
│  ── Step 3: Reflection ──  │
│  [ What I learned input ]  │  ← TextFormField (multiline, max 3 lines)
│  [ Feedback input ]        │  ← TextFormField (multiline, max 3 lines)
│                           │
│  [ Complete Class ]        │  ← Primary button (disabled until all done)
└───────────────────────────┘
```

### Step Completion Rules
- Submit button **disabled** until: QR scanned AND GPS captured AND both text fields filled
- QR must match `currentRecord.sessionId` — show error if mismatch

### On Submit
1. Calls `currentRecord.copyWith(...)` with checkout data
2. Calls `CheckInService.updateCheckOut(updatedRecord)`
3. Updates `CheckInNotifier.currentRecord` to null (session complete)
4. Adds record to `sessionHistory`
5. Navigates: `context.go(AppRoutes.home.path)`

### State (Provider)
- Reads: `CheckInNotifier.currentRecord` (to get sessionId for QR validation)
- Local: `_gpsLocation`, `_sessionId`, `_formKey`
- Writes to: `CheckInNotifier`

### Atoms Used
- `StepSectionLabel`
- `StatusIndicator`

---

## Reusable Atoms (Shared Components)

> **AI Instruction (Week 5):** Build atoms first, then assemble into screens.
> Each atom is a single file. No atom file exceeds 100 lines.

### `StatusCard`
**File:** `lib/features/home/widgets/status_card.dart`
- Props: `CheckInStatus? status`
- Renders title, icon, and background color based on status
- Uses `AppRadius.lg`, `AppSpacing.md`

### `SessionHistoryItem`
**File:** `lib/features/home/widgets/session_history_item.dart`
- Props: `CheckInRecord record`
- Shows: date, topic, mood emoji, completion chip
- One row, tappable (no navigation for MVP)

### `MoodSelector`
**File:** `lib/shared/widgets/mood_selector.dart`
- Props: `int? selectedScore`, `ValueChanged<int> onSelected`
- Renders 5 `MoodTile` atoms from `MoodOption.all`
- Selected tile: `AppColors.primaryLight` border `AppColors.primary`
- Unselected tile: `AppColors.surfaceVariant`

### `StepSectionLabel`
**File:** `lib/shared/widgets/step_section_label.dart`
- Props: `String stepNumber`, `String title`, `bool isComplete`
- Shows step number chip + label + checkmark if complete

### `StatusIndicator`
**File:** `lib/shared/widgets/status_indicator.dart`
- Props: `bool isLoading`, `bool isSuccess`, `String? message`
- Shows: spinner (loading) → success icon + message (done) → idle state

---

## AI Hallucination Warnings

> ⚠️ Do NOT put GPS or QR logic inside `build()` or button `onPressed` inline. Delegate to services.

> ⚠️ Do NOT show both "Check In" and "Finish Class" buttons simultaneously on HomeScreen.

> ⚠️ Do NOT create a separate screen for history — it is a list section on HomeScreen.

> ⚠️ Do NOT add a bottom navigation bar.

> ⚠️ `FinishClassScreen` must validate QR matches `currentRecord.sessionId` before enabling submit.
