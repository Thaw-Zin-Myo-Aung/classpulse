# DATA_MODELS.md
# ClassPulse — Data Models Contract

> **AI Instruction:** This file is the source of truth for all data structures in ClassPulse.
> Do NOT invent field names. Do NOT change types. Always use `fromJson`/`toJson`.
> Handle all nullable fields with `?`. Never hardcode IDs.

---

## 1. CheckInRecord

The primary data entity. Represents one complete class session for a student.
Created at check-in, updated at check-out.

### JSON Contract

```json
{
  "id": "uuid-string",
  "studentId": "6731503088",
  "sessionId": "extracted-from-qr-code",
  "checkInTime": "2026-03-13T08:00:00.000Z",
  "checkInLat": 20.0453,
  "checkInLng": 99.8923,
  "previousTopic": "Backend Integration and API Design",
  "expectedTopic": "Midterm Lab Test",
  "moodBefore": 4,
  "status": "checked_in",
  "checkOutTime": null,
  "checkOutLat": null,
  "checkOutLng": null,
  "learningSummary": null,
  "classFeedback": null
}
```

### Field Definitions

| Field | Dart Type | Nullable | Description |
|-------|-----------|----------|-------------|
| `id` | `String` | No | UUID — generated locally via `uuid` package |
| `studentId` | `String` | No | Student ID number |
| `sessionId` | `String` | No | Extracted from QR code scan |
| `checkInTime` | `DateTime` | No | Device timestamp at check-in |
| `checkInLat` | `double` | No | GPS latitude at check-in |
| `checkInLng` | `double` | No | GPS longitude at check-in |
| `previousTopic` | `String` | No | What was covered in previous class |
| `expectedTopic` | `String` | No | What student expects to learn today |
| `moodBefore` | `int` | No | 1–5 mood score before class |
| `status` | `CheckInStatus` | No | Enum: `checkedIn` or `completed` |
| `checkOutTime` | `DateTime?` | Yes | Device timestamp at check-out |
| `checkOutLat` | `double?` | Yes | GPS latitude at check-out |
| `checkOutLng` | `double?` | Yes | GPS longitude at check-out |
| `learningSummary` | `String?` | Yes | What the student learned today |
| `classFeedback` | `String?` | Yes | Feedback on instructor or class |

### Dart Class

```dart
import 'package:classpulse/core/enums/check_in_status.dart';

class CheckInRecord {
  final String id;
  final String studentId;
  final String sessionId;
  final DateTime checkInTime;
  final double checkInLat;
  final double checkInLng;
  final String previousTopic;
  final String expectedTopic;
  final int moodBefore;
  final CheckInStatus status;
  final DateTime? checkOutTime;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? learningSummary;
  final String? classFeedback;

  const CheckInRecord({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.checkInTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.previousTopic,
    required this.expectedTopic,
    required this.moodBefore,
    required this.status,
    this.checkOutTime,
    this.checkOutLat,
    this.checkOutLng,
    this.learningSummary,
    this.classFeedback,
  });

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      sessionId: json['sessionId'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkInLat: (json['checkInLat'] as num).toDouble(),
      checkInLng: (json['checkInLng'] as num).toDouble(),
      previousTopic: json['previousTopic'] as String,
      expectedTopic: json['expectedTopic'] as String,
      moodBefore: json['moodBefore'] as int,
      status: CheckInStatus.fromString(json['status'] as String),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      checkOutLat: json['checkOutLat'] != null
          ? (json['checkOutLat'] as num).toDouble()
          : null,
      checkOutLng: json['checkOutLng'] != null
          ? (json['checkOutLng'] as num).toDouble()
          : null,
      learningSummary: json['learningSummary'] as String?,
      classFeedback: json['classFeedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'sessionId': sessionId,
      'checkInTime': checkInTime.toIso8601String(),
      'checkInLat': checkInLat,
      'checkInLng': checkInLng,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'moodBefore': moodBefore,
      'status': status.value,
      'checkOutTime': checkOutTime?.toIso8601String(),
      'checkOutLat': checkOutLat,
      'checkOutLng': checkOutLng,
      'learningSummary': learningSummary,
      'classFeedback': classFeedback,
    };
  }

  /// Creates a copy with updated fields (used when completing check-out)
  CheckInRecord copyWith({
    CheckInStatus? status,
    DateTime? checkOutTime,
    double? checkOutLat,
    double? checkOutLng,
    String? learningSummary,
    String? classFeedback,
  }) {
    return CheckInRecord(
      id: id,
      studentId: studentId,
      sessionId: sessionId,
      checkInTime: checkInTime,
      checkInLat: checkInLat,
      checkInLng: checkInLng,
      previousTopic: previousTopic,
      expectedTopic: expectedTopic,
      moodBefore: moodBefore,
      status: status ?? this.status,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkOutLat: checkOutLat ?? this.checkOutLat,
      checkOutLng: checkOutLng ?? this.checkOutLng,
      learningSummary: learningSummary ?? this.learningSummary,
      classFeedback: classFeedback ?? this.classFeedback,
    );
  }
}
```

---

## 2. CheckInStatus (Enum)

Tracks the lifecycle state of a class session.

```dart
enum CheckInStatus {
  checkedIn('checked_in'),
  completed('completed');

  const CheckInStatus(this.value);
  final String value;

  static CheckInStatus fromString(String value) {
    return CheckInStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CheckInStatus.checkedIn,
    );
  }
}
```

---

## 3. MoodOption

Helper model for rendering the mood selector UI.

### JSON Contract

```json
{
  "score": 4,
  "emoji": "🙂",
  "label": "Positive"
}
```

### Dart Class

```dart
class MoodOption {
  final int score;
  final String emoji;
  final String label;

  const MoodOption({
    required this.score,
    required this.emoji,
    required this.label,
  });

  /// Static list — source of truth for mood scale
  static const List<MoodOption> all = [
    MoodOption(score: 1, emoji: '😡', label: 'Very Negative'),
    MoodOption(score: 2, emoji: '🙁', label: 'Negative'),
    MoodOption(score: 3, emoji: '😐', label: 'Neutral'),
    MoodOption(score: 4, emoji: '🙂', label: 'Positive'),
    MoodOption(score: 5, emoji: '😄', label: 'Very Positive'),
  ];
}
```

---

## 4. GPS Location (Value Object)

Used internally by `LocationService`. Not persisted as its own document —
latitude and longitude are stored directly on `CheckInRecord`.

```dart
class GpsLocation {
  final double latitude;
  final double longitude;
  final DateTime capturedAt;

  const GpsLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
  });
}
```

---

## 5. Firestore Collection Structure

```
firestore/
└── checkins/                     ← Collection
    └── {checkInRecord.id}/       ← Document (keyed by UUID)
        ├── id
        ├── studentId
        ├── sessionId
        ├── checkInTime
        ├── checkInLat
        ├── checkInLng
        ├── previousTopic
        ├── expectedTopic
        ├── moodBefore
        ├── status
        ├── checkOutTime          ← null until Finish Class
        ├── checkOutLat           ← null until Finish Class
        ├── checkOutLng           ← null until Finish Class
        ├── learningSummary       ← null until Finish Class
        └── classFeedback         ← null until Finish Class
```

> **AI Instruction:** The same document is created at check-in and **updated** (not replaced)
> at check-out using the record's `id`. Use Firestore's `update()` method, not `set()`.

---

## 6. SQLite Local Schema

For offline-first storage. Mirrors Firestore fields exactly.

```sql
CREATE TABLE checkins (
  id               TEXT PRIMARY KEY,
  studentId        TEXT NOT NULL,
  sessionId        TEXT NOT NULL,
  checkInTime      TEXT NOT NULL,
  checkInLat       REAL NOT NULL,
  checkInLng       REAL NOT NULL,
  previousTopic    TEXT NOT NULL,
  expectedTopic    TEXT NOT NULL,
  moodBefore       INTEGER NOT NULL,
  status           TEXT NOT NULL DEFAULT 'checked_in',
  checkOutTime     TEXT,
  checkOutLat      REAL,
  checkOutLng      REAL,
  learningSummary  TEXT,
  classFeedback    TEXT
);
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT use `json['checkInTime'] as DateTime` — JSON stores dates as Strings. Always use `DateTime.parse()`.

> ⚠️ Do NOT use `(json['checkInLat'] as double)` directly — JSON numbers may be `int`. Always cast via `(json['checkInLat'] as num).toDouble()`.

> ⚠️ Do NOT invent a separate `CheckOutRecord` class — check-out fields are part of `CheckInRecord` and updated via `copyWith()`.

> ⚠️ Do NOT store `GpsLocation` as a Firestore document — flatten lat/lng directly into `CheckInRecord`.
