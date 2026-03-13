import 'package:classpulse/core/enums/check_in_status.dart';
import 'package:classpulse/models/check_in_record.dart';
import 'package:classpulse/services/checkin_service.dart';
import 'package:flutter/material.dart';

class CheckInNotifier extends ChangeNotifier {
  CheckInService? _service;

  CheckInNotifier({CheckInService? service}) : _service = service;

  CheckInRecord? _currentRecord;
  List<CheckInRecord> _sessionHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  CheckInRecord? get currentRecord => _currentRecord;
  List<CheckInRecord> get sessionHistory => _sessionHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CheckInStatus? get currentStatus => _currentRecord?.status;

  CheckInService _getServiceSync() {
    return _service ??= CheckInService();
  }

  Future<void> loadHistory() async {
    _setLoading(true);
    try {
      final all = await _getServiceSync().getAllRecords();
      _sessionHistory = all
          .where((r) => r.status == CheckInStatus.completed)
          .toList(growable: false);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load session history.';
    } finally {
      _setLoading(false);
    }
  }

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
      _currentRecord = await _getServiceSync().saveCheckIn(
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

  Future<void> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String learningSummary,
    required String classFeedback,
  }) async {
    if (_currentRecord == null) return;

    _setLoading(true);
    try {
      final completed = await _getServiceSync().saveCheckOut(
        currentRecord: _currentRecord!,
        checkOutLat: checkOutLat,
        checkOutLng: checkOutLng,
        learningSummary: learningSummary,
        classFeedback: classFeedback,
      );
      _sessionHistory = [completed, ..._sessionHistory];
      _currentRecord = null;
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
