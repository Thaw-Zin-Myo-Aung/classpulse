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
| Local Storage (Offline Cache) | Hive + hive_flutter | ^2.2.3 |
| Cloud Database | Firebase Firestore | ^5.0.0 |
| Deployment | Firebase Hosting | — |
| GPS | geolocator | ^12.0.0 |
| QR Scanner | mobile_scanner | ^5.0.0 |
| Font | Plus Jakarta Sans (google_fonts) | ^6.2.1 |
| ID Generation | uuid | ^4.4.0 |

> ⚠️ SQLite (`sqflite`) has been removed. Do NOT use it anywhere.

---

## 3. Folder Structure

```
classpulse/
├── lib/
│   ├── main.dart                         # App entry point, Hive.initFlutter(), MultiProvider, MaterialApp.router
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── app_radius.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── app_routes.dart
│   │   ├── providers/
│   │   │   └── check_in_notifier.dart
│   │   └── enums/
│   │       └── check_in_status.dart
│   ├── models/
│   │   ├── check_in_record.dart
│   │   ├── mood_option.dart
│   │   └── gps_location.dart
│   ├── services/
│   │   ├── location_service.dart         # GPS — geolocator
│   │   ├── qr_service.dart               # QR parsing — mobile_scanner
│   │   ├── session_service.dart          # Firestore sessions READ ONLY
│   │   ├── checkin_service.dart          # Hive cache + Firestore source of truth
│   │   └── hive_helper.dart              # Hive box singleton (replaces DatabaseHelper)
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
├── docs/
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
┌────────────────────────────────────────┐
│              UI LAYER                  │
│   Screens + Atoms (features/, shared/) │
│   → NO business logic here             │
│   → Only calls notifier or local state │
├────────────────────────────────────────┤
│           STATE LAYER                  │
│   CheckInNotifier (core/providers/)    │
│   → Bridges UI and Services            │
│   → Holds currentRecord + history      │
├────────────────────────────────────────┤
│          SERVICE LAYER                 │
│   LocationService, QRService,          │
│   SessionService, CheckInService       │
│   → All business logic lives here      │
│   → No Flutter widgets                 │
├────────────────────────────────────────┤
│           DATA LAYER                   │
│   Firestore = source of truth          │
│     • sessions collection (READ ONLY)  │
│     • checkins collection (READ/WRITE) │
│   Hive = offline cache only            │
│     • Falls back when offline          │
└────────────────────────────────────────┘
```

---

## 5. Data Flow: Sessions & Check-in History

```
App starts
    │
    ▼
SessionService.getSession(sessionId)
    └── reads from Firestore sessions collection
            └── sessions are mock data seeded manually (READ ONLY)

CheckInService.getAllRecords()
    └── tries Firestore checkins collection first
            └── on failure / offline → falls back to Hive local cache

CheckInService.saveCheckIn() / saveCheckOut()
    └── saves to Hive first (immediate, offline-safe)
            └── then syncs to Firestore (fire-and-forget)
```

---

## 6. Key Architectural Rules

| Rule | Source |
|------|--------|
| Never write GPS/DB calls in `build()` or `onPressed` inline | Week 6 Golden Rule |
| Use `context.go()` exclusively — no `Navigator.push()` | NAVIGATION.md |
| Use `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius` — no hardcoded values | THEME.md |
| `CheckInNotifier` is the ONLY global ChangeNotifier | STATE.md |
| Firestore is source of truth — Hive is offline fallback cache | SERVICES.md |
| No bottom navigation bar | SCREENS.md |
| Always `.timeout(Duration(seconds: 10))` on GPS and Firestore calls | Week 6 |
| All model classes have `fromJson`, `toJson`, `copyWith` | DATA_MODELS.md |
| Never use `sqflite` or `DatabaseHelper` — they are removed | This file |
| `sessions` collection is READ ONLY — never write to it from the app | SERVICES.md |

---

## 7. Firestore Collections (Mock Data)

### `sessions` — READ ONLY
Seeded manually. One document: `MAD-W07-2026`

### `checkins` — READ/WRITE
Mock documents seeded manually for demo:
- `mock-checkin-001` (2026-03-06, Backend Integration)
- `mock-checkin-002` (2026-02-27, AI Tools for Mobile)

New check-ins written by app during live demo.

---

## 8. pubspec.yaml Dependencies

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

  # Local Storage (Offline Cache)
  hive: ^2.2.3
  hive_flutter: ^1.1.0

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

## 9. Build Order for AI

```
Step 1  → core/theme/         (AppColors, AppTextStyles, AppSpacing, AppRadius, AppTheme)
Step 2  → core/enums/         (CheckInStatus)
Step 3  → models/             (GpsLocation, MoodOption, CheckInRecord)
Step 4  → core/router/        (AppRoutes, appRouter)
Step 5  → services/hive_helper.dart       (Hive box singleton)
Step 6  → services/location_service.dart
Step 7  → services/qr_service.dart
Step 8  → services/session_service.dart   (Firestore READ ONLY)
Step 9  → services/checkin_service.dart   (Hive + Firestore)
Step 10 → core/providers/check_in_notifier.dart
Step 11 → main.dart           (Hive.initFlutter() + MultiProvider + MaterialApp.router)
Step 12 → shared/widgets/
Step 13 → features/splash/
Step 14 → features/home/
Step 15 → features/checkin/
Step 16 → features/checkout/
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT use `sqflite`, `DatabaseHelper`, or any SQLite-related code. It is removed.

> ⚠️ Do NOT create files outside the folder structure defined in Section 3.

> ⚠️ Do NOT add authentication, login screens, or user registration.

> ⚠️ Do NOT add a bottom navigation bar.

> ⚠️ Do NOT install packages not listed in Section 8.

> ⚠️ Do NOT write to the `sessions` collection. It is READ ONLY.

> ⚠️ Always call `Hive.initFlutter()` in `main()` before `runApp()`.
