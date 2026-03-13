import 'package:classpulse/core/enums/check_in_status.dart';
import 'package:classpulse/models/check_in_record.dart';
import 'package:classpulse/services/hive_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class CheckInService {
  final FirebaseFirestore _firestore;
  final HiveHelper _cache;

  CheckInService({FirebaseFirestore? firestore, HiveHelper? cache})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _cache = cache ?? HiveHelper.instance();

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

    await _cache.saveRecord(record);
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

    await _cache.updateRecord(updated);
    _syncToFirestore(updated);
    return updated;
  }

  Future<List<CheckInRecord>> getAllRecords() async {
    try {
      final snap = await _firestore
          .collection('checkins')
          .orderBy('checkInTime', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      final records = snap.docs
          .map((d) => _normalizeFirestoreJson(d.data()))
          .map(CheckInRecord.fromJson)
          .toList();

      for (final r in records) {
        try {
          await _cache.saveRecord(r);
        } catch (_) {
          // Cache failures are non-fatal.
        }
      }

      return records;
    } catch (e) {
      debugPrint('Firestore history load failed, using cache: $e');
      return _cache.getAllRecords();
    }
  }

  Map<String, dynamic> _normalizeFirestoreJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);

    final checkInTime = mapped['checkInTime'];
    if (checkInTime is Timestamp) {
      mapped['checkInTime'] = checkInTime.toDate().toIso8601String();
    }

    final checkOutTime = mapped['checkOutTime'];
    if (checkOutTime is Timestamp) {
      mapped['checkOutTime'] = checkOutTime.toDate().toIso8601String();
    }

    return mapped;
  }

  void _syncToFirestore(CheckInRecord record) {
    _firestore
        .collection('checkins')
        .doc(record.id)
        .set(record.toJson())
        .timeout(const Duration(seconds: 10))
        .catchError((e) {
      debugPrint('Firestore sync failed: $e');
    });
  }
}
