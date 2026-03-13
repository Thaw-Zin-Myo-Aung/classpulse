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
┌───────────────────────────┘
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
Main hub. Shows current session status, BOTH action buttons, and session history list.

### Layout
```
┌───────────────────────────┘
│  AppBar: "ClassPulse"      │  ← AppTextStyles.titleLarge, no back button
├───────────────────────────┤
│                           │
│  ┌───────────────────┘  │  ← StatusCard
│  │  🟣 Ready to Check In │  │
│  │  Today, 13 Mar 2026   │  │
│  └───────────────────┘  │
│                           │
│  [ ✔ Check In          ]  │  ← Always ENABLED (primary button)
│  [ 🏁 Check Out         ]  │  ← DIMMED when not checked in
│                           │
│  ─── Recent Sessions ───  │  ← Section label
│  [ Session History List ] │  ← SessionHistoryItem atoms
│                           │
└───────────────────────────┘
```

### Button Logic

> **AI Instruction:** ALWAYS render BOTH buttons. Use `enabled` property to control interactivity.
> Do NOT conditionally show/hide buttons. Do NOT use `Visibility` or `if` to toggle them.

| Button | Label | Color when enabled | When enabled | Navigates To |
|--------|-------|-------------------|--------------|-------------|
| Check In | "Check In" | `AppColors.primary` | **Always** | `/checkin` |
| Check Out | "Check Out" | `AppColors.primary` | Only when `currentRecord != null && status == checkedIn` | `/finish` |

**Check Out disabled appearance:**
- Background: `AppColors.surfaceVariant`
- Text: `AppColors.textSecondary`
- `onPressed: null` (Flutter auto-dims when null)
- Do NOT show tooltip or error — just visually dimmed

### Status Card States

| Status | Icon | Title | Card Background |
|--------|------|-------|-----------------|
| `null` (no session) | `🟣` | "Ready to Check In" | `AppColors.surface` |
| `checkedIn` | `⏳` | "Class In Progress" | `AppColors.primaryLight` |
| `completed` | `✅` | "Class Completed!" | `Color(0xFFE8F5E9)` |

### Session History List
- Shows all past `CheckInRecord` where `status == completed`
- Each item: `SessionHistoryItem` atom
- Empty state: centered text "No sessions yet" in `AppTextStyles.bodyMedium`
- Loaded from `CheckInService.getAllRecords()` in `initState`

### State (Provider)
- Reads: `CheckInNotifier.currentRecord` (nullable `CheckInRecord`)
- Reads: `CheckInNotifier.sessionHistory` (List<CheckInRecord>)
- Calls: `CheckInNotifier.loadHistory()` on `initState`

### Atoms Used
- `StatusCard` — displays session state
- `SessionHistoryItem` — one row per past session
- `ActionButton` — reusable button atom used for both buttons

---

## Screen 3: CheckInScreen

**Route:** `/checkin`  
**File:** `lib/features/checkin/check_in_screen.dart`

### Purpose
Captures GPS location, QR scan, and pre-class reflection. Creates a new `CheckInRecord`.

### Layout
```
┌───────────────────────────┘
│  AppBar: "Check In"        │  ← back button disabled
├───────────────────────────┤
│  ── Step 1: Location ──   │
│  [ 📍 Get My Location ]    │  ← Outlined button → LocationService
│  "Lat: 20.04 | Lng: 99.89" │  ← Shows after capture
│                           │
│  ── Step 2: QR Code ───   │
│  [ 📷 Scan QR Code ]      │  ← Outlined button → opens QR scanner
│  "Session: MAD-W07"       │  ← Shows sessionId after scan
│  [ Use Demo QR ]          │  ← TextButton for demo (calls getMockSessionId)
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
┌───────────────────────────┘
│  AppBar: "Finish Class"    │  ← back button disabled
├───────────────────────────┤
│  ── Step 1: QR Code ───   │
│  [ 📷 Scan QR Code ]      │  ← Must match check-in sessionId
│  "Session: MAD-W07 ✓"    │
│  [ Use Demo QR ]          │  ← TextButton for demo
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
- QR must match `currentRecord.sessionId` — show error snackbar if mismatch

### On Submit
1. Calls `currentRecord.copyWith(...)` with checkout data
2. Calls `CheckInService.saveCheckOut(updatedRecord)`
3. Updates `CheckInNotifier.currentRecord` to null
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

### `ActionButton`
**File:** `lib/shared/widgets/action_button.dart`
- Props: `String label`, `IconData icon`, `VoidCallback? onPressed`, `bool isPrimary`
- When `onPressed == null`: Flutter auto-dims (disabled state)
- `isPrimary: true` → filled style with `AppColors.primary`
- `isPrimary: false` → outlined style
- Used for both Check In and Check Out buttons on HomeScreen

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

> ⚠️ ALWAYS render BOTH buttons on HomeScreen. Use `onPressed: null` to disable Check Out, not `Visibility` or `if`.

> ⚠️ Do NOT create a separate screen for history — it is a list section on HomeScreen.

> ⚠️ Do NOT add a bottom navigation bar.

> ⚠️ `FinishClassScreen` must validate QR matches `currentRecord.sessionId` before enabling submit.

> ⚠️ Check In button is ALWAYS enabled — the user can check in anytime for demo purposes.
