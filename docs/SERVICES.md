# SERVICES.md
# ClassPulse — Service Layer Contract

> **AI Instruction:** This is the Service Layer. All business logic, GPS, QR, and data operations live here.
> **Golden Rule (Week 6):** NEVER write service calls inside a widget `build()` method or button `onPressed` inline.
> All services are plain Dart classes. No Flutter widgets inside services.
> Services return typed results. Always handle errors with try/catch — never let exceptions bubble to UI.

---

## Architecture Overview

```
UI Screen
    │
    ▼  calls
Service Layer          ← This file defines everything here
    ├── LocationService    (GPS)
    ├── QRService          (Camera + QR parsing)
    ├── SessionService     (Firestore sessions — READ ONLY)
    ├── CheckInService     (Hive cache + Firestore source of truth)
    └── HiveHelper         (Local offline box)
         │
         ▼  persists to
    ├── Hive (offline cache — write first)
    └── Firestore (source of truth — sync after)
```

> ⚠️ SQLite (`sqflite`) and `DatabaseHelper` are REMOVED. Do NOT use them.

---

## 0. Firestore Seed Data (Manual Setup Required)

> **Developer Instruction:** Before running the app, seed the following collections
> via Firebase Console or `gcloud firestore documents create` in Cloud Shell.

### Collection: `sessions` — READ ONLY

Document ID: `MAD-W07-2026`

| Field | Type | Value |
|-------|------|-------|
| `sessionId` | string | `MAD-W07-2026` |
| `courseName` | string | `Mobile Application Development` |
| `instructor` | string | `Vittayasak Rujivorakul` |
| `date` | string | `2026-03-13` |
| `room` | string | `S3-407` |

### Collection: `checkins` — Mock Previous Sessions

Document ID: `mock-checkin-001`

| Field | Type | Value |
|-------|------|-------|
| `id` | string | `mock-checkin-001` |
| `studentId` | string | `6731503088` |
| `sessionId` | string | `MAD-W07-2026` |
| `checkInTime` | string | `2026-03-06T09:00:00` |
| `checkOutTime` | string | `2026-03-06T11:00:00` |
| `previousTopic` | string | `Backend Integration` |
| `expectedTopic` | string | `Service Layer Design` |
| `learningSummary` | string | `Learned how to structure service layers` |
| `classFeedback` | string | `Great class, very practical` |
| `moodBefore` | number | `4` |
| `checkInLat` | number | `20.0454` |
| `checkInLng` | number | `99.8923` |
| `checkOutLat` | number | `20.0454` |
| `checkOutLng` | number | `99.8923` |
| `status` | string | `completed` |

Document ID: `mock-checkin-002`

| Field | Type | Value |
|-------|------|-------|
| `id` | string | `mock-checkin-002` |
| `studentId` | string | `6731503088` |
| `sessionId` | string | `MAD-W07-2026` |
| `checkInTime` | string | `2026-02-27T09:00:00` |
| `checkOutTime` | string | `2026-02-27T11:00:00` |
| `previousTopic` | string | `AI Tools for Mobile` |
| `expectedTopic` | string | `Backend & API Design` |
| `learningSummary` | string | `Explored Copilot for Flutter development` |
| `classFeedback` | string | `Really helpful for project setup` |
| `moodBefore` | number | `5` |
| `checkInLat` | number | `20.0454` |
| `checkInLng` | number | `99.8923` |
| `checkOutLat` | number | `20.0454` |
| `checkOutLng` | number | `99.8923` |
| `status` | string | `completed` |

### QR Code for Demo
Generate at [qr-code-generator.com](https://www.qr-code-generator.com) with exact text:
```
CLASSPULSE-MAD-W07-2026
```

---

## 1. LocationService

**File:** `lib/services/location_service.dart`  
**Package:** `geolocator: ^12.0.0`

### Method Contract

```dart
class LocationService {
  Future<GpsLocation> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationException('Location permission denied.');
    }
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled.');
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw LocationException('Location request timed out.'),
    );
    return GpsLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      capturedAt: DateTime.now(),
    );
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  @override
  String toString() => 'LocationException: $message';
}
```

---

## 2. QRService

**File:** `lib/services/qr_service.dart`  
**Package:** `mobile_scanner: ^5.0.0`

### QR Code Format
```
CLASSPULSE-{sessionId}
```
Example: `CLASSPULSE-MAD-W07-2026`

### Method Contract

```dart
class QRService {
  String parseQRResult(String rawValue) {
    const prefix = 'CLASSPULSE-';
    if (!rawValue.startsWith(prefix)) {
      throw QRException('Invalid QR code. Not a ClassPulse session QR.');
    }
    final sessionId = rawValue.substring(prefix.length).trim();
    if (sessionId.isEmpty) throw QRException('QR code contains no session ID.');
    return sessionId;
  }

  String getMockSessionId() => 'MAD-W07-2026';
}

class QRException implements Exception {
  final String message;
  const QRException(this.message);
  @override
  String toString() => 'QRException: $message';
}
```

---

## 3. SessionService

**File:** `lib/services/session_service.dart`  
**Package:** `cloud_firestore: ^5.0.0`

### Responsibility
- Fetch session info from Firestore `sessions` collection by sessionId
- **READ ONLY** — never writes to `sessions`

### Method Contract

```dart
class SessionService {
  final FirebaseFirestore _firestore;

  SessionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getSession(String sessionId) async {
    try {
      final doc = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .get()
          .timeout(const Duration(seconds: 10));
      if (!doc.exists || doc.data() == null) {
        throw SessionException('Session not found: $sessionId');
      }
      return doc.data()!;
    } catch (e) {
      if (e is SessionException) rethrow;
      throw SessionException('Could not load session. Check your connection.');
    }
  }
}

class SessionException implements Exception {
  final String message;
  const SessionException(this.message);
  @override
  String toString() => 'SessionException: $message';
}
```

---

## 4. HiveHelper

**File:** `lib/services/hive_helper.dart`  
**Packages:** `hive: ^2.2.3`, `hive_flutter: ^1.1.0`

### Responsibility
- Manage Hive box as offline cache for `CheckInRecord`
- Initialized once in `main()` via `Hive.initFlutter()`

### Method Contract

```dart
class HiveHelper {
  static const String _boxName = 'checkins';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_boxName);
  }

  static Box<Map> get _box => Hive.box<Map>(_boxName);

  Future<void> saveRecord(CheckInRecord record) async {
    await _box.put(record.id, record.toJson());
  }

  Future<void> updateRecord(CheckInRecord record) async {
    await _box.put(record.id, record.toJson());
  }

  List<CheckInRecord> getAllRecords() {
    return _box.values
        .map((m) => CheckInRecord.fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  }
}
```

### Initialize in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await HiveHelper.init();   // ← must be before runApp()
  runApp(const ClassPulseApp());
}
```

---

## 5. CheckInService

**File:** `lib/services/checkin_service.dart`  
**Packages:** `hive_flutter`, `cloud_firestore: ^5.0.0`, `uuid: ^4.4.0`

### Write Strategy: Hive First, Then Firestore
```
User submits → Save to Hive (immediate, offline-safe)
                    └── Sync to Firestore (async, fire-and-forget)
                              └── If Firestore fails → log error, do NOT block user
```

### Read Strategy: Firestore First, Hive Fallback
```
getAllRecords()
    └── try Firestore checkins (source of truth)
            └── on error / offline → return Hive cache
```

### Method Contract

```dart
class CheckInService {
  final HiveHelper _hive;
  final FirebaseFirestore _firestore;

  CheckInService({HiveHelper? hive, FirebaseFirestore? firestore})
      : _hive = hive ?? HiveHelper(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<CheckInRecord> saveCheckIn({
    required String studentId,
    required String sessionId,
    required double checkInLat,
    required double checkInLng,
    required String previousTopic,
    required String expectedTopic,
    required int moodBefore,
  }) async {
    final record = CheckInRecord(
      id: const Uuid().v4(),
      studentId: studentId,
      sessionId: sessionId,
      checkInTime: DateTime.now(),
      checkInLat: checkInLat,
      checkInLng: checkInLng,
      previousTopic: previousTopic,
      expectedTopic: expectedTopic,
      moodBefore: moodBefore,
      status: CheckInStatus.checkedIn,
    );
    await _hive.saveRecord(record);
    _syncToFirestore(record);
    return record;
  }

  Future<CheckInRecord> saveCheckOut({
    required CheckInRecord currentRecord,
    required double checkOutLat,
    required double checkOutLng,
    required String learningSummary,
    required String classFeedback,
  }) async {
    final updated = currentRecord.copyWith(
      status: CheckInStatus.completed,
      checkOutTime: DateTime.now(),
      checkOutLat: checkOutLat,
      checkOutLng: checkOutLng,
      learningSummary: learningSummary,
      classFeedback: classFeedback,
    );
    await _hive.updateRecord(updated);
    _syncToFirestore(updated);
    return updated;
  }

  /// Reads from Firestore first. Falls back to Hive if offline or error.
  Future<List<CheckInRecord>> getAllRecords() async {
    try {
      final snapshot = await _firestore
          .collection('checkins')
          .orderBy('checkInTime', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));
      final records = snapshot.docs
          .map((d) => CheckInRecord.fromJson(d.data()))
          .toList();
      // Cache to Hive for offline use
      for (final r in records) {
        await _hive.saveRecord(r);
      }
      return records;
    } catch (e) {
      debugPrint('Firestore read failed, using Hive cache: $e');
      return _hive.getAllRecords();
    }
  }

  void _syncToFirestore(CheckInRecord record) {
    _firestore
        .collection('checkins')
        .doc(record.id)
        .set(record.toJson())
        .catchError((e) => debugPrint('Firestore sync failed: $e'));
  }
}
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT use `sqflite`, `DatabaseHelper`, or any SQLite code — it is removed.

> ⚠️ Do NOT call any service inside `build()` or button `onPressed` directly.

> ⚠️ Do NOT let Firestore errors crash the app. All Firestore calls are best-effort.

> ⚠️ Do NOT use `Geolocator.getLastKnownPosition()` — always use `getCurrentPosition()`.

> ⚠️ Do NOT invent QR formats. Only valid format: `CLASSPULSE-{sessionId}`.

> ⚠️ Always include `.timeout(Duration(seconds: 10))` on GPS and Firestore calls.

> ⚠️ The `sessions` collection is READ ONLY. Never write to it.

> ⚠️ Always call `HiveHelper.init()` in `main()` before `runApp()`.
