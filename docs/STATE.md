# STATE.md
# ClassPulse — State Management Contract

> **AI Instruction:** Use **Provider** for all state management. No Riverpod, no Bloc, no GetX.
> There is ONE global notifier: `CheckInNotifier`.
> All other state is local (`StatefulWidget`) to its screen.
> If AI writes isolated state that doesn't share data between screens — that is the Week 3 "screens with amnesia" bug. Reject it.

---

## 1. State Architecture Overview

```
main.dart
    └── MultiProvider
            └── ChangeNotifierProvider<CheckInNotifier>   ← GLOBAL
                    │
                    ├── HomeScreen         (reads currentRecord, sessionHistory)
                    ├── CheckInScreen      (writes currentRecord)
                    └── FinishClassScreen  (reads + writes currentRecord)
```

---

## 2. Global State: `CheckInNotifier`

**File:** `lib/core/providers/check_in_notifier.dart`

### What it holds

| Field | Type | Description |
|-------|------|-------------|
| `currentRecord` | `CheckInRecord?` | Active session. `null` = no session in progress |
| `sessionHistory` | `List<CheckInRecord>` | All completed sessions, ordered newest first |
| `isLoading` | `bool` | True while saving/updating data |
| `errorMessage` | `String?` | Last error message. `null` = no error |

### What it exposes

```dart
import 'package:flutter/material.dart';
import 'package:classpulse/models/check_in_record.dart';
import 'package:classpulse/services/checkin_service.dart';

class CheckInNotifier extends ChangeNotifier {
  final CheckInService _service;

  CheckInNotifier({CheckInService? service})
      : _service = service ?? CheckInService();

  // ——— State Fields ———
  CheckInRecord? _currentRecord;
  List<CheckInRecord> _sessionHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ——— Getters ———
  CheckInRecord? get currentRecord => _currentRecord;
  List<CheckInRecord> get sessionHistory => _sessionHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Derived: current session status
  CheckInStatus? get currentStatus => _currentRecord?.status;

  // ——— Actions ———

  /// Load session history from SQLite on app start
  Future<void> loadHistory() async {
    _setLoading(true);
    try {
      _sessionHistory = await _service.getAllRecords();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load session history.';
    } finally {
      _setLoading(false);
    }
  }

  /// Called when student submits Check-in form
  Future<void> checkIn({
    required String studentId,
    required String sessionId,
    required double checkInLat,
    required double checkInLng,
    required String previousTopic,
    required String expectedTopic,
    required int moodBefore,
  }) async {
    _setLoading(true);
    try {
      _currentRecord = await _service.saveCheckIn(
        studentId: studentId,
        sessionId: sessionId,
        checkInLat: checkInLat,
        checkInLng: checkInLng,
        previousTopic: previousTopic,
        expectedTopic: expectedTopic,
        moodBefore: moodBefore,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Check-in failed. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Called when student submits Finish Class form
  Future<void> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String learningSummary,
    required String classFeedback,
  }) async {
    if (_currentRecord == null) return;
    _setLoading(true);
    try {
      final completed = await _service.saveCheckOut(
        currentRecord: _currentRecord!,
        checkOutLat: checkOutLat,
        checkOutLng: checkOutLng,
        learningSummary: learningSummary,
        classFeedback: classFeedback,
      );
      _sessionHistory = [completed, ..._sessionHistory];
      _currentRecord = null;  // session is done
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to complete class. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
```

---

## 3. Local State (Per Screen)

Local state is managed with `StatefulWidget` + `setState()`. It is NOT shared globally.

### CheckInScreen Local State

| Field | Type | Description |
|-------|------|-------------|
| `_gpsLocation` | `GpsLocation?` | Captured GPS. `null` = not yet captured |
| `_sessionId` | `String?` | Parsed from QR. `null` = not yet scanned |
| `_selectedMood` | `int?` | 1–5 mood score. `null` = not selected |
| `_isGpsLoading` | `bool` | True while GPS is being fetched |
| `_isQrScanning` | `bool` | True while QR scanner is open |
| `_formKey` | `GlobalKey<FormState>` | For text field validation |

### FinishClassScreen Local State

| Field | Type | Description |
|-------|------|-------------|
| `_gpsLocation` | `GpsLocation?` | Captured GPS at check-out |
| `_sessionId` | `String?` | Scanned QR session ID (must match `currentRecord.sessionId`) |
| `_isGpsLoading` | `bool` | True while GPS is being fetched |
| `_isQrScanning` | `bool` | True while QR scanner is open |
| `_qrMismatch` | `bool` | True if scanned QR doesn't match current session |
| `_formKey` | `GlobalKey<FormState>` | For text field validation |

### HomeScreen Local State
- **None.** HomeScreen is fully driven by `CheckInNotifier` global state.

### SplashScreen Local State
- **None.** Only uses `initState` timer.

---

## 4. Provider Setup in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/router/app_router.dart';
import 'package:classpulse/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ClassPulseApp());
}

class ClassPulseApp extends StatelessWidget {
  const ClassPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckInNotifier()..loadHistory()),
      ],
      child: MaterialApp.router(
        title: 'ClassPulse',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

---

## 5. How Screens Read & Write State

### Reading (HomeScreen)
```dart
// Read without rebuilding entire tree
final notifier = context.watch<CheckInNotifier>();
final status = notifier.currentStatus;       // null / checkedIn / completed
final history = notifier.sessionHistory;     // List<CheckInRecord>
```

### Writing (CheckInScreen)
```dart
// Write — do NOT use context.watch here, use read
await context.read<CheckInNotifier>().checkIn(
  studentId: '6731503088',
  sessionId: _sessionId!,
  checkInLat: _gpsLocation!.latitude,
  checkInLng: _gpsLocation!.longitude,
  previousTopic: _previousTopicController.text,
  expectedTopic: _expectedTopicController.text,
  moodBefore: _selectedMood!,
);
```

### Writing (FinishClassScreen)
```dart
await context.read<CheckInNotifier>().checkOut(
  checkOutLat: _gpsLocation!.latitude,
  checkOutLng: _gpsLocation!.longitude,
  learningSummary: _learningController.text,
  classFeedback: _feedbackController.text,
);
```

---

## 6. State Flow Diagram

```
App Launch
    │
    ▼
CheckInNotifier.loadHistory()       ← populates sessionHistory from SQLite
    │
    ▼
HomeScreen reads:
  currentStatus == null              → shows "Check In" button
    │
    ▼ User taps Check In
CheckInScreen (local state collects GPS, QR, form)
    │
    ▼ User submits
CheckInNotifier.checkIn(...)        → currentRecord set, status = checkedIn
    │
    ▼ navigate to Home
HomeScreen reads:
  currentStatus == checkedIn         → shows "Finish Class" button
    │
    ▼ User taps Finish Class
FinishClassScreen (local state collects QR, GPS, form)
    │
    ▼ User submits
CheckInNotifier.checkOut(...)       → currentRecord = null, added to sessionHistory
    │
    ▼ navigate to Home
HomeScreen reads:
  currentStatus == null              → no button shown, history list updated
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT use `context.watch<CheckInNotifier>()` inside button `onPressed`. Use `context.read()`.

> ⚠️ Do NOT create separate Providers for GPS or QR state — those are local `StatefulWidget` state.

> ⚠️ Do NOT call `notifyListeners()` from inside a `build()` method.

> ⚠️ Do NOT use `setState()` to update `currentRecord` or `sessionHistory` — those belong to `CheckInNotifier`.

> ⚠️ `CheckInNotifier` is the ONLY `ChangeNotifier` in this app. Do NOT create additional notifiers.
