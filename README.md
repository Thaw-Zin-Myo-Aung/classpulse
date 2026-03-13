# ClassPulse 🎓

> Smart Class Check-in & Learning Reflection — Mobile Application Development Midterm

**Author:** Thaw Zin Myo Aung (6731503088)  
**Course:** 1305216 Mobile Application Development  
**University:** Mae Fah Luang University  

---

## What is ClassPulse?

ClassPulse is a Flutter app that replaces manual attendance with a GPS-verified, QR-based check-in system. Students check in at the start of class and check out at the end — capturing mood, learning topics, and feedback along the way.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter + Dart |
| State | Provider |
| Navigation | GoRouter |
| Cloud DB | Firebase Firestore |
| Offline Cache | Hive |
| GPS | geolocator |
| QR | mobile_scanner |

---

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Firebase project: `classpulse88`
- `google-services.json` placed in `android/app/`
- `GoogleService-Info.plist` placed in `ios/Runner/`

### Install & Run
```bash
flutter pub get
flutter run
```

---

## Seed Firestore Mock Data

Run in **Google Cloud Shell** (console.cloud.google.com):

```bash
# Session
gcloud firestore documents create \
  projects/classpulse88/databases/(default)/documents/sessions/MAD-W07-2026 \
  --fields='sessionId=string:MAD-W07-2026,courseName=string:Mobile Application Development,instructor=string:Vittayasak Rujivorakul,date=string:2026-03-13,room=string:S3-407'

# Mock Check-in 1
gcloud firestore documents create \
  projects/classpulse88/databases/(default)/documents/checkins/mock-checkin-001 \
  --fields='id=string:mock-checkin-001,studentId=string:6731503088,sessionId=string:MAD-W07-2026,checkInTime=string:2026-03-06T09:00:00,checkOutTime=string:2026-03-06T11:00:00,previousTopic=string:Backend Integration,expectedTopic=string:Service Layer Design,learningSummary=string:Learned how to structure service layers,classFeedback=string:Great class very practical,moodBefore=integer:4,checkInLat=double:20.0454,checkInLng=double:99.8923,checkOutLat=double:20.0454,checkOutLng=double:99.8923,status=string:completed'

# Mock Check-in 2
gcloud firestore documents create \
  projects/classpulse88/databases/(default)/documents/checkins/mock-checkin-002 \
  --fields='id=string:mock-checkin-002,studentId=string:6731503088,sessionId=string:MAD-W07-2026,checkInTime=string:2026-02-27T09:00:00,checkOutTime=string:2026-02-27T11:00:00,previousTopic=string:AI Tools for Mobile,expectedTopic=string:Backend and API Design,learningSummary=string:Explored Copilot for Flutter development,classFeedback=string:Really helpful for project setup,moodBefore=integer:5,checkInLat=double:20.0454,checkInLng=double:99.8923,checkOutLat=double:20.0454,checkOutLng=double:99.8923,status=string:completed'
```

---

## QR Code for Demo

Generate at [qr-code-generator.com](https://www.qr-code-generator.com) with this exact text:

```
CLASSPULSE-MAD-W07-2026
```

Or use the **"Use Demo QR"** button inside the app.

---

## Project Structure

```
lib/
├── main.dart                    # Entry point — Hive.initFlutter() + Firebase + runApp()
├── core/
│   ├── theme/                   # AppColors, AppTextStyles, AppSpacing, AppRadius
│   ├── router/                  # GoRouter config + AppRoutes
│   ├── providers/               # CheckInNotifier (only global state)
│   └── enums/                   # CheckInStatus
├── models/                      # CheckInRecord, GpsLocation, MoodOption
├── services/
│   ├── hive_helper.dart         # Hive offline cache
│   ├── location_service.dart    # GPS
│   ├── qr_service.dart          # QR parsing
│   ├── session_service.dart     # Firestore sessions (READ ONLY)
│   └── checkin_service.dart     # Firestore + Hive check-in logic
├── features/
│   ├── splash/                  # SplashScreen
│   ├── home/                    # HomeScreen + CheckInCard + CheckOutCard + SessionHistoryItem
│   ├── checkin/                 # CheckInScreen
│   └── checkout/                # FinishClassScreen
└── shared/widgets/              # ActionButton, MoodSelector, StepSectionLabel, StatusIndicator
```

---

## Architecture

```
UI Layer        → screens + widgets (no business logic)
State Layer     → CheckInNotifier (Provider)
Service Layer   → LocationService, QRService, SessionService, CheckInService
Data Layer      → Firestore (source of truth) + Hive (offline cache)
```

**Write flow:** Hive first → Firestore async (fire-and-forget)  
**Read flow:** Firestore first → Hive fallback on failure

---

## Screens

| Screen | Route | Purpose |
|--------|-------|---------|
| SplashScreen | `/splash` | Brand entry, auto-redirect |
| HomeScreen | `/home` | Status cards + session history |
| CheckInScreen | `/checkin` | GPS + QR + reflection at start |
| FinishClassScreen | `/finish` | QR + GPS + reflection at end |

---

## Docs

All architecture decisions are documented in `/docs`:

| File | Contents |
|------|----------|
| `ARCHITECTURE.md` | Tech stack, folder structure, build order |
| `SERVICES.md` | Service contracts + method signatures |
| `DATA_MODELS.md` | Dart model schemas |
| `SCREENS.md` | Screen layouts and state flows |
| `STATE.md` | CheckInNotifier contract |
| `NAVIGATION.md` | GoRouter config |
| `THEME.md` | Colors, typography, spacing |

---

## Key Rules (for AI / Copilot)

- ⚠️ Never use `sqflite` — Hive only for local storage
- ⚠️ Never call services inside `build()` or `onPressed` inline
- ⚠️ Firestore errors must never crash the app
- ⚠️ `sessions` collection is READ ONLY
- ⚠️ Always `.timeout(Duration(seconds: 10))` on GPS and Firestore calls
- ⚠️ No bottom navigation bar
- ⚠️ No authentication
