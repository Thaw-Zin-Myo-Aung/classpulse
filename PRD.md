# Product Requirement Document (PRD)
# ClassPulse — Smart Class Check-in & Learning Reflection App

**Version:** 1.0  
**Date:** 13 March 2026  
**Author:** Thaw Zin Myo Aung (6731503088)  
**Course:** 1305216 Mobile Application Development

---

## 1. Problem Statement

Universities rely on manual attendance systems that cannot verify physical presence or engagement. There is no feedback loop connecting students' learning expectations to actual outcomes. ClassPulse solves this by combining GPS + QR-based presence verification with structured pre/post-class reflection, giving instructors real attendance data and learning insights.

---

## 2. Target User

| User | Description |
|------|-------------|
| **Student** | University student who checks in to class and reflects on learning |
| **Instructor** | Course lecturer who generates QR codes and views attendance data |

Primary user for this MVP: **Student**

---

## 3. Feature List

### Core Features
- **GPS Check-in** — Records student's coordinates and timestamp on arrival
- **QR Code Scanner** — Validates student is in the correct classroom by scanning instructor's QR
- **Pre-Class Reflection Form** — Captures previous topic recall, today's expectation, and mood (1–5)
- **Post-Class Reflection Form** — Captures what was learned and feedback for the instructor
- **Check-out (Finish Class)** — Re-scans QR + records GPS at end of session
- **Data Persistence** — Stores all check-in/out records locally (SQLite) and syncs to Firebase Firestore

### Supporting Features
- Home screen showing today's class status (Not Started / Checked In / Completed)
- Simple session history list

---

## 4. User Flow

```
App Launch
    │
    ▼
Home Screen ──── [Status: Not Started]
    │
    ▼ Tap "Check In"
Check-in Screen
    ├── 1. Get GPS Location (auto)
    ├── 2. Scan QR Code
    └── 3. Fill Pre-Class Form
            ├── Previous topic covered
            ├── Expected topic today
            └── Mood (1–5 emoji scale)
    │
    ▼ Submit → [Status: Checked In]
Home Screen
    │
    ▼ Tap "Finish Class"
Finish Class Screen
    ├── 1. Scan QR Code again
    ├── 2. Get GPS Location (auto)
    └── 3. Fill Post-Class Form
            ├── What did you learn today?
            └── Feedback for instructor
    │
    ▼ Submit → [Status: Completed]
Home Screen
```

---

## 5. Data Fields

### CheckIn Record
| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Auto-generated UUID |
| `studentId` | String | Student identifier |
| `sessionId` | String | Extracted from QR code |
| `checkInTime` | Timestamp | Device timestamp on check-in |
| `checkInLat` | double | GPS latitude at check-in |
| `checkInLng` | double | GPS longitude at check-in |
| `previousTopic` | String | What was covered last class |
| `expectedTopic` | String | What student expects to learn |
| `moodBefore` | int | 1–5 mood score |
| `status` | String | `checked_in` / `completed` |

### CheckOut Record (appended to same document)
| Field | Type | Description |
|-------|------|-------------|
| `checkOutTime` | Timestamp | Timestamp on finish |
| `checkOutLat` | double | GPS latitude at check-out |
| `checkOutLng` | double | GPS longitude at check-out |
| `learningSummary` | String | What the student learned |
| `classFeedback` | String | Feedback on instructor/class |

---

## 6. Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|----------|
| **Framework** | Flutter (Dart) | Cross-platform, course requirement |
| **State Management** | Provider | Lightweight, sufficient for MVP scope |
| **Navigation** | GoRouter | Clean declarative routing |
| **Local Storage** | SQLite (`sqflite`) | Offline-first data persistence |
| **Cloud Database** | Firebase Firestore | Real-time sync, easy Flutter integration |
| **Deployment** | Firebase Hosting | Flutter Web deployment (course requirement) |
| **GPS** | `geolocator` package | Device location retrieval |
| **QR Scanner** | `mobile_scanner` package | Camera-based QR scanning |
| **Architecture** | Feature-based folder structure + Service Layer | Separation of concerns |

---

## 7. Architecture Overview

```
lib/
├── core/              # Theme, constants, router
├── features/
│   ├── checkin/       # Check-in screen + logic
│   ├── checkout/      # Finish class screen + logic
│   └── home/          # Home screen + status display
├── services/
│   ├── location_service.dart   # GPS — never in UI layer
│   ├── qr_service.dart         # QR scanning logic
│   └── checkin_service.dart    # Firestore + SQLite operations
└── models/
    └── checkin_record.dart     # Data model with fromJson/toJson
```

> **Golden Rule:** No GPS or database calls inside UI widgets. All logic is isolated in the Service Layer.

---

## 8. AI Usage Plan

AI tools (GitHub Copilot, Claude) will be used to:
- Generate Flutter widget scaffolding and navigation boilerplate
- Generate `fromJson`/`toJson` data models
- Generate Service Layer templates
