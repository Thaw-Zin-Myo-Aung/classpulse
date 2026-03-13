# ARCHITECTURE.md
# ClassPulse — Master Architecture Blueprint

> **AI Instruction:** This is your mission briefing. Read ALL files in the `docs/` folder before writing any code.
> This file is the index. Every decision is documented in the referenced files.
> Do NOT invent architecture. Do NOT deviate from the folder structure below.
> You are the junior developer. The architect has made all decisions. Your job is to implement them precisely.

---

## 1. Project Identity

| Field | Value |
|-------|-------|
| **App Name** | ClassPulse |
| **Purpose** | Smart class check-in and learning reflection for university students |
| **Platform** | Flutter (iOS + Android + Web) |
| **Course** | 1305216 Mobile Application Development, Mae Fah Luang University |
| **Author** | Thaw Zin Myo Aung (6731503088) |

---

## 2. Tech Stack

| Layer | Technology | Version |
|-------|-----------|--------|
| Framework | Flutter + Dart | Latest stable |
| State Management | Provider | ^6.1.2 |
| Navigation | GoRouter | ^14.0.0 |
| Local Storage | sqflite | ^2.3.3 |
| Cloud Database | Firebase Firestore | ^5.0.0 |
| Deployment | Firebase Hosting | — |
| GPS | geolocator | ^12.0.0 |
| QR Scanner | mobile_scanner | ^5.0.0 |
| Font | Plus Jakarta Sans (google_fonts) | ^6.2.1 |
| ID Generation | uuid | ^4.4.0 |

---

## 3. Folder Structure

```
classpulse/
├── lib/
│   ├── main.dart                         # App entry point, MultiProvider, MaterialApp.router
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart            # ThemeData (lightTheme only)
│   │   │   ├── app_colors.dart           # AppColors constants
│   │   │   ├── app_text_styles.dart      # AppTextStyles
│   │   │   ├── app_spacing.dart          # AppSpacing constants
│   │   │   └── app_radius.dart           # AppRadius constants
│   │   ├── router/
│   │   │   ├── app_router.dart           # GoRouter config
│   │   │   └── app_routes.dart           # AppRoutes enum
│   │   ├── providers/
│   │   │   └── check_in_notifier.dart    # ONLY global ChangeNotifier
│   │   └── enums/
│   │       └── check_in_status.dart      # CheckInStatus enum
│   ├── models/
│   │   ├── check_in_record.dart          # CheckInRecord + fromJson/toJson/copyWith
│   │   ├── mood_option.dart              # MoodOption + static list
│   │   └── gps_location.dart             # GpsLocation value object
│   ├── services/
│   │   ├── location_service.dart         # GPS — geolocator
│   │   ├── qr_service.dart               # QR parsing — mobile_scanner
│   │   ├── checkin_service.dart          # SQLite + Firestore operations
│   │   └── database_helper.dart          # SQLite singleton
│   ├── features/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── status_card.dart
│   │   │       └── session_history_item.dart
│   │   ├── checkin/
│   │   │   └── check_in_screen.dart
│   │   └── checkout/
│   │       └── finish_class_screen.dart
│   └── shared/
│       └── widgets/
│           ├── mood_selector.dart
│           ├── step_section_label.dart
│           └── status_indicator.dart
├── docs/                                 # AI context documents (this folder)
│   ├── ARCHITECTURE.md                   # ← You are here
│   ├── DATA_MODELS.md
│   ├── THEME.md
│   ├── NAVIGATION.md
│   ├── SCREENS.md
│   ├── SERVICES.md
│   └── STATE.md
├── PRD.md
└── README.md
```

---

## 4. Layered Architecture

```
┌────────────────────────────────────────└
│              UI LAYER                    │
│   Screens + Atoms (features/, shared/)   │
│   → NO business logic here               │
│   → Only calls notifier or local state   │
├────────────────────────────────────────┤
│           STATE LAYER                    │
│   CheckInNotifier (core/providers/)      │
│   → Bridges UI and Services              │
│   → Holds currentRecord + sessionHistory │
├────────────────────────────────────────┤
│          SERVICE LAYER                   │
│   LocationService, QRService,            │
│   CheckInService (services/)             │
│   → All business logic lives here        │
│   → No Flutter widgets                  │
├────────────────────────────────────────┤
│           DATA LAYER                     │
│   SQLite (DatabaseHelper) + Firestore    │
│   → SQLite = source of truth for UI      │
│   → Firestore = cloud backup only        │
└────────────────────────────────────────┘
```

---

## 5. Key Architectural Rules

| Rule | Source |
|------|--------|
| Never write GPS/DB calls in `build()` or `onPressed` inline | Week 6 Golden Rule |
| Use `context.go()` exclusively — no `Navigator.push()` | NAVIGATION.md |
| Use `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius` — no hardcoded values | THEME.md |
| `CheckInNotifier` is the ONLY global ChangeNotifier | STATE.md |
| SQLite is source of truth — Firestore is fire-and-forget backup | SERVICES.md |
| No bottom navigation bar | SCREENS.md |
| Always `.timeout(Duration(seconds: 10))` on GPS calls | Week 6 Elevator Test |
| All model classes have `fromJson`, `toJson`, `copyWith` | DATA_MODELS.md |

---

## 6. Reference Index

| File | Read When |
|------|-----------|
| `DATA_MODELS.md` | Creating any Dart model class or Firestore/SQLite schema |
| `THEME.md` | Writing any widget with color, font, padding, or radius |
| `NAVIGATION.md` | Setting up routing or any `context.go()` call |
| `SCREENS.md` | Building any screen or atom widget |
| `SERVICES.md` | Implementing LocationService, QRService, or CheckInService |
| `STATE.md` | Writing CheckInNotifier, Provider setup, or screen state |

---

## 7. pubspec.yaml Dependencies

```yaml
name: classpulse
description: Smart Class Check-in & Learning Reflection App
publish_to: none
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Navigation
  go_router: ^14.0.0

  # State Management
  provider: ^6.1.2

  # Firebase
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  firebase_hosting: # via CLI only

  # Local Storage
  sqflite: ^2.3.3
  path: ^1.9.0

  # GPS
  geolocator: ^12.0.0

  # QR Scanner
  mobile_scanner: ^5.0.0

  # Font
  google_fonts: ^6.2.1

  # Utilities
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## 8. Build Order for AI

Follow this sequence when generating code. Do NOT skip steps.

```
Step 1 → core/theme/         (AppColors, AppTextStyles, AppSpacing, AppRadius, AppTheme)
Step 2 → core/enums/         (CheckInStatus)
Step 3 → models/             (GpsLocation, MoodOption, CheckInRecord)
Step 4 → core/router/        (AppRoutes, appRouter)
Step 5 → services/           (DatabaseHelper, LocationService, QRService, CheckInService)
Step 6 → core/providers/     (CheckInNotifier)
Step 7 → main.dart           (MultiProvider + MaterialApp.router)
Step 8 → shared/widgets/     (MoodSelector, StepSectionLabel, StatusIndicator)
Step 9 → features/splash/    (SplashScreen)
Step 10 → features/home/     (StatusCard, SessionHistoryItem, HomeScreen)
Step 11 → features/checkin/  (CheckInScreen)
Step 12 → features/checkout/ (FinishClassScreen)
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT create files outside the folder structure defined in Section 3.

> ⚠️ Do NOT add authentication, login screens, or user registration — there is NO auth in this app.

> ⚠️ Do NOT add a bottom navigation bar.

> ⚠️ Do NOT install packages not listed in Section 7. Verify every package on pub.dev before using.

> ⚠️ Do NOT write code beyond Step 12 until all previous steps are verified working.
