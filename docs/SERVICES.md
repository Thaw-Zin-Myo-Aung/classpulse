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
    ├── LocationService   (GPS)
    ├── QRService         (Camera + QR parsing)
    ├── SessionService    (Firestore session lookup)
    └── CheckInService    (SQLite + Firestore)
         │
         ▼  persists to
    ├── SQLite (offline-first)
    └── Firestore (cloud sync)
```

---

## 0. Firestore Seed Data (Manual Setup Required)

> **Developer Instruction:** Before running the app, manually create the following
> in Firebase Console → Firestore → Start collection.
> This is static mock data. It does NOT change during the exam.

### Collection: `sessions`

Create one document with ID: `MAD-W07-2026`

| Field | Type | Value |
|-------|------|-------|
| `sessionId` | string | `MAD-W07-2026` |
| `courseName` | string | `Mobile Application Development` |
| `instructor` | string | `Vittayasak Rujivorakul` |
| `date` | string | `2026-03-13` |
| `room` | string | `S3-407` |

### Collection: `checkins`
> **Auto-created** by the app on first check-in submission. Do NOT create manually.

### QR Code for Demo
Generate a QR code at [qr-code-generator.com](https://www.qr-code-generator.com) with this exact text:
```
CLASSPULSE-MAD-W07-2026
```
Print or display on screen to scan during demo.

---

## 1. LocationService

**File:** `lib/services/location_service.dart`  
**Package:** `geolocator: ^12.0.0`

### Responsibility
- Request location permission
- Return current GPS coordinates as `GpsLocation`
- Handle permission denied and GPS disabled gracefully

### Method Contract

```dart
class LocationService {
  /// Requests permission if not granted, then returns current GPS location.
  /// Throws [LocationException] if permission denied or GPS disabled.
  Future<GpsLocation> getCurrentLocation() async {
    // 1. Check & request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationException('Location permission denied.');
    }

    // 2. Check if GPS is enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled.');
    }

    // 3. Get position with timeout
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

/// Custom exception for location errors
class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  
  @override
  String toString() => 'LocationException: \$message';
}
```

### Error States to Handle in UI
| Error | Message to Show User |
|-------|---------------------|
| Permission denied | "Location permission required. Please enable in settings." |
| GPS disabled | "Please enable GPS to check in." |
| Timeout | "Could not get location. Please try again." |

### Required pubspec.yaml
```yaml
dependencies:
  geolocator: ^12.0.0
```

### Required Permissions
**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```
**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ClassPulse needs your location to verify class attendance.</string>
```

---

## 2. QRService

**File:** `lib/services/qr_service.dart`  
**Package:** `mobile_scanner: ^5.0.0`

### Responsibility
- Open camera for QR scanning
- Parse raw QR string to extract `sessionId`
- Validate QR belongs to ClassPulse format
- Provide mock QR fill for demo/debug purposes

### QR Code Format

Expected QR string format:
```
CLASSPULSE-{sessionId}
```
Example:
```
CLASSPULSE-MAD-W07-2026
```

> **AI Instruction:** QR codes contain plain strings in the format `CLASSPULSE-{sessionId}`.
> Do NOT expect JSON. Do NOT invent other formats.

### Method Contract

```dart
class QRService {
  /// Parses a raw QR scan result string and extracts the sessionId.
  /// Returns sessionId string if valid ClassPulse QR.
  /// Throws [QRException] if format is invalid.
  String parseQRResult(String rawValue) {
    const prefix = 'CLASSPULSE-';
    if (!rawValue.startsWith(prefix)) {
      throw QRException('Invalid QR code. Not a ClassPulse session QR.');
    }
    final sessionId = rawValue.substring(prefix.length).trim();
    if (sessionId.isEmpty) {
      throw QRException('QR code contains no session ID.');
    }
    return sessionId;
  }

  /// Returns mock session ID for demo/debug without real QR scan.
  /// ONLY use this for testing. Remove before production.
  String getMockSessionId() => 'MAD-W07-2026';
}

/// Custom exception for QR errors
class QRException implements Exception {
  final String message;
  const QRException(this.message);

  @override
  String toString() => 'QRException: \$message';
}
```

### QR Scanner Widget Integration

```dart
// Usage in CheckInScreen / FinishClassScreen:
MobileScanner(
  controller: MobileScannerController(),
  onDetect: (capture) {
    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue;
    if (raw != null) {
      try {
        final sessionId = qrService.parseQRResult(raw);
        // update local state with sessionId
      } catch (e) {
        // show error snackbar
      }
    }
  },
);
```

### Mock QR Button (For Demo)
> **AI Instruction:** Add a small **"Use Demo QR"** `TextButton` below the scanner area.
> When tapped, it calls `qrService.getMockSessionId()` and sets `_sessionId` as if scanned.
> Label it clearly as "Demo Mode" so the instructor knows it's intentional.

```dart
// In CheckInScreen and FinishClassScreen below the MobileScanner widget:
TextButton.icon(
  onPressed: () {
    final mockId = QRService().getMockSessionId();
    setState(() => _sessionId = mockId);
  },
  icon: const Icon(Icons.bug_report_outlined, size: 16),
  label: const Text('Use Demo QR'),
  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
),
```

### Error States to Handle in UI
| Error | Message to Show User |
|-------|---------------------|
| Invalid QR format | "This QR code is not a ClassPulse session code." |
| Session ID mismatch (Finish only) | "QR code does not match your current session." |
| Camera permission denied | "Camera permission required to scan QR code." |

### Required pubspec.yaml
```yaml
dependencies:
  mobile_scanner: ^5.0.0
```

### Required Permissions
**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
```
**iOS** (`Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>ClassPulse needs camera access to scan class QR codes.</string>
```

---

## 3. SessionService

**File:** `lib/services/session_service.dart`  
**Package:** `cloud_firestore: ^5.0.0`

### Responsibility
- Fetch session info from Firestore `sessions` collection by sessionId
- Validates that a session exists before allowing check-in

### Method Contract

```dart
class SessionService {
  final FirebaseFirestore _firestore;

  SessionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches session document from Firestore.
  /// Returns session data map if found.
  /// Throws [SessionException] if not found.
  Future<Map<String, dynamic>> getSession(String sessionId) async {
    try {
      final doc = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists || doc.data() == null) {
        throw SessionException('Session not found: \$sessionId');
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
  String toString() => 'SessionException: \$message';
}
```

---

## 4. CheckInService

**File:** `lib/services/checkin_service.dart`  
**Packages:** `sqflite: ^2.3.3`, `cloud_firestore: ^5.0.0`, `uuid: ^4.4.0`

### Responsibility
- Save new `CheckInRecord` to SQLite first, then Firestore
- Update existing record at check-out
- Retrieve all completed session records from SQLite
- Generate UUID for new records

### Write Strategy: SQLite First, Then Firestore
```
User submits → Save to SQLite (immediate) → Save to Firestore (async, best-effort)
                      │
              If Firestore fails → log error, do NOT block user
```

> **AI Instruction:** Firestore failures must NEVER crash the app or block the user.
> SQLite is the source of truth for the UI. Firestore is cloud backup.

### Method Contract

```dart
class CheckInService {
  final DatabaseHelper _db;
  final FirebaseFirestore _firestore;

  CheckInService({DatabaseHelper? db, FirebaseFirestore? firestore})
      : _db = db ?? DatabaseHelper.instance,
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
    await _db.insertRecord(record);
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
    await _db.updateRecord(updated);
    _syncToFirestore(updated);
    return updated;
  }

  Future<List<CheckInRecord>> getAllRecords() async {
    return await _db.getAllRecords();
  }

  void _syncToFirestore(CheckInRecord record) {
    _firestore
        .collection('checkins')
        .doc(record.id)
        .set(record.toJson())
        .catchError((e) {
      debugPrint('Firestore sync failed: \$e');
    });
  }
}
```

---

## 5. DatabaseHelper (SQLite)

**File:** `lib/services/database_helper.dart`

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('classpulse.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
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
      )
    ''');
  }

  Future<void> insertRecord(CheckInRecord record) async {
    final db = await database;
    await db.insert('checkins', record.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRecord(CheckInRecord record) async {
    final db = await database;
    await db.update('checkins', record.toJson(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<List<CheckInRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('checkins', orderBy: 'checkInTime DESC');
    return maps.map((m) => CheckInRecord.fromJson(m)).toList();
  }
}
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT call `LocationService` or `QRService` inside `build()` or button callbacks directly.

> ⚠️ Do NOT let Firestore errors crash the app. `_syncToFirestore()` is fire-and-forget.

> ⚠️ Do NOT use `Geolocator.getLastKnownPosition()` — always use `getCurrentPosition()`.

> ⚠️ Do NOT invent QR formats. The only valid format is `CLASSPULSE-{sessionId}`.

> ⚠️ Do NOT read history from Firestore — always read from SQLite (`getAllRecords()`).

> ⚠️ Always include `.timeout(Duration(seconds: 10))` on GPS and Firestore calls.

> ⚠️ The `sessions` collection is READ ONLY from the app. Never write to it.
