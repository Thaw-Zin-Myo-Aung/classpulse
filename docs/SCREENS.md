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
│      [ Logo Icon ]        │  ← fade-in animation
│       ClassPulse          │  ← AppTextStyles.displayLarge (white)
│   Smart Class Check-in    │  ← AppTextStyles.bodyMedium (white 70%)
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

---

## Screen 2: HomeScreen

**Route:** `/home`  
**File:** `lib/features/home/home_screen.dart`

### Purpose
Main hub. Three sections: CheckInCard, CheckOutCard, and Previous Sessions list.

### Layout
```
┌───────────────────────────┘
│  AppBar: "ClassPulse"      │  ← no back button
├───────────────────────────┤
│                           │
│  ┌───────────────────┘  │  ← CheckInCard
│  │ 📚 Mobile App Dev    │  │     course name from Firestore
│  │ Today, 13 Mar 2026   │  │     date
│  │ [ ✔ Check In      ] │  │     ALWAYS enabled
│  └───────────────────┘  │
│                           │
│  ┌───────────────────┘  │  ← CheckOutCard
│  │ 📚 Mobile App Dev    │  │     same course name
│  │ Status: In Progress  │  │     status text
│  │ [ 🏁 Check Out     ] │  │     DIMMED if not checked in
│  └───────────────────┘  │
│                           │
│  ─── Previous Sessions ──  │  ← section label
│  [ SessionHistoryItem ]   │
│  [ SessionHistoryItem ]   │
│  "No sessions yet"        │  ← empty state
│                           │
└───────────────────────────┘
```

---

## HomeScreen Atoms

### `CheckInCard`
**File:** `lib/features/home/widgets/check_in_card.dart`

- Props: `String courseName`, `String dateLabel`, `VoidCallback onCheckIn`
- Always renders with **enabled** Check In button
- Layout inside card:
  - Row: `Icons.menu_book_rounded` + `courseName` (AppTextStyles.titleMedium)
  - `dateLabel` (AppTextStyles.bodySmall, AppColors.textSecondary)
  - Full-width primary `ActionButton` label "Check In", icon `Icons.check_circle_outline`
- Card background: `AppColors.surface`
- Border: 1px `AppColors.primary` with 30% opacity

> **AI Instruction:** `courseName` is fetched from Firestore `sessions/MAD-W07-2026`.
> It is passed DOWN as a prop from HomeScreen. Do NOT fetch Firestore inside this widget.

---

### `CheckOutCard`
**File:** `lib/features/home/widgets/check_out_card.dart`

- Props: `String courseName`, `String statusLabel`, `VoidCallback? onCheckOut`
- `onCheckOut` is `null` when user has NOT checked in — Flutter auto-dims the button
- Layout inside card:
  - Row: `Icons.menu_book_rounded` + `courseName` (AppTextStyles.titleMedium)
  - `statusLabel` (AppTextStyles.bodySmall):
    - Not checked in: "Check in first to enable" (AppColors.textSecondary)
    - Checked in: "Class in progress" (AppColors.primary)
  - Full-width `ActionButton` label "Check Out", icon `Icons.flag_rounded`
    - `onPressed: onCheckOut` (null = dimmed automatically)
- Card background: `AppColors.surface`
- Border: 1px `AppColors.surfaceVariant`

> **AI Instruction:** `onCheckOut` is `null` when `currentRecord == null`.
> Pass `() => context.go('/finish')` when `currentRecord != null`.

---

### `SessionHistoryItem`
**File:** `lib/features/home/widgets/session_history_item.dart`

- Props: `CheckInRecord record`
- Layout (one row):
  - Left: date + sessionId
  - Right: mood emoji + green "Completed" chip
- Uses `AppTextStyles.bodySmall`, `AppSpacing.sm`

---

## HomeScreen State & Data Flow

```
initState:
  1. SessionService.getSession('MAD-W07-2026') → store courseName in local state
  2. CheckInNotifier.loadHistory() → loads past records from SQLite

build:
  CheckInCard(
    courseName: _courseName,       ← from Firestore (local state)
    dateLabel: 'Today, 13 Mar',
    onCheckIn: () => context.go('/checkin'),
  )

  CheckOutCard(
    courseName: _courseName,
    statusLabel: currentRecord != null ? 'Class in progress' : 'Check in first to enable',
    onCheckOut: currentRecord != null ? () => context.go('/finish') : null,
  )

  ListView of sessionHistory
```

### State Variables (HomeScreen)
- `_courseName` (String) — loaded from Firestore in `initState`, default `'Loading...'`
- `_isLoadingCourse` (bool) — shows shimmer/spinner in card while fetching
- Reads from Provider: `CheckInNotifier.currentRecord`, `CheckInNotifier.sessionHistory`

> **AI Instruction:** If `SessionService.getSession()` fails, set `_courseName = 'Mobile App Dev'` as fallback.
> Never crash the screen if Firestore is unavailable.

---

## Screen 3: CheckInScreen

**Route:** `/checkin`  
**File:** `lib/features/checkin/check_in_screen.dart`

### Layout
```
┌───────────────────────────┘
│  AppBar: "Check In"        │  ← back button disabled
├───────────────────────────┤
│  ── Step 1: Location ──   │
│  [ 📍 Get My Location ]    │  ← Outlined button → LocationService
│  "Lat: 20.04 | Lng: 99.89" │
│                           │
│  ── Step 2: QR Code ───   │
│  [ 📷 Scan QR Code ]      │
│  "Session: MAD-W07 ✓"    │
│  [ Use Demo QR ]          │  ← TextButton (demo only)
│                           │
│  ── Step 3: Reflection ──  │
│  [ Previous Topic input ]  │
│  [ Expected Topic input ]  │
│  [ Mood Selector ]         │
│                           │
│  [ Submit Check In ]       │  ← disabled until all steps done
└───────────────────────────┘
```

### On Submit
1. Calls `CheckInService.saveCheckIn(...)`
2. Updates `CheckInNotifier.currentRecord`
3. Navigates: `context.go(AppRoutes.home.path)`

### State
- Local: `_gpsLocation`, `_sessionId`, `_moodScore`, `_formKey`
- Writes to: `CheckInNotifier`

### Atoms Used
- `StepSectionLabel`, `MoodSelector`, `StatusIndicator`

---

## Screen 4: FinishClassScreen

**Route:** `/finish`  
**File:** `lib/features/checkout/finish_class_screen.dart`

### Layout
```
┌───────────────────────────┘
│  AppBar: "Finish Class"    │  ← back button disabled
├───────────────────────────┤
│  ── Step 1: QR Code ───   │
│  [ 📷 Scan QR Code ]      │  ← must match check-in sessionId
│  [ Use Demo QR ]          │
│                           │
│  ── Step 2: Location ──   │
│  [ 📍 Get My Location ]    │
│                           │
│  ── Step 3: Reflection ──  │
│  [ What I learned input ]  │
│  [ Feedback input ]        │
│                           │
│  [ Complete Class ]        │  ← disabled until all done
└───────────────────────────┘
```

### On Submit
1. Calls `CheckInService.saveCheckOut(...)`
2. Sets `CheckInNotifier.currentRecord` to null
3. Adds to `sessionHistory`
4. Navigates: `context.go(AppRoutes.home.path)`

### State
- Reads: `CheckInNotifier.currentRecord`
- Local: `_gpsLocation`, `_sessionId`, `_formKey`

### Atoms Used
- `StepSectionLabel`, `StatusIndicator`

---

## Shared Atoms

> **AI Instruction:** Build atoms first, then assemble into screens. No atom file exceeds 100 lines.

### `ActionButton`
**File:** `lib/shared/widgets/action_button.dart`
- Props: `String label`, `IconData icon`, `VoidCallback? onPressed`, `bool isPrimary`
- `onPressed == null` → Flutter auto-dims
- `isPrimary: true` → filled `AppColors.primary`
- `isPrimary: false` → outlined

### `MoodSelector`
**File:** `lib/shared/widgets/mood_selector.dart`
- Props: `int? selectedScore`, `ValueChanged<int> onSelected`
- 5 emoji mood tiles

### `StepSectionLabel`
**File:** `lib/shared/widgets/step_section_label.dart`
- Props: `String stepNumber`, `String title`, `bool isComplete`

### `StatusIndicator`
**File:** `lib/shared/widgets/status_indicator.dart`
- Props: `bool isLoading`, `bool isSuccess`, `String? message`

---

## AI Hallucination Warnings

> ⚠️ HomeScreen has THREE sections: `CheckInCard`, `CheckOutCard`, `Previous Sessions list`. Do NOT merge them.

> ⚠️ `courseName` is fetched ONCE in HomeScreen `initState` via `SessionService`. Pass it as a prop to both cards.

> ⚠️ `CheckOutCard` button uses `onPressed: null` when not checked in — never use `Visibility` or `if` to hide it.

> ⚠️ Check In button is ALWAYS enabled.

> ⚠️ Do NOT fetch Firestore inside widget `build()` methods.

> ⚠️ Do NOT add a bottom navigation bar.

> ⚠️ If Firestore fails, fallback `_courseName = 'Mobile App Dev'` — never crash the screen.
