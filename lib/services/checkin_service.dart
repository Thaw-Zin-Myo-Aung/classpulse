import 'package:classpulse/core/enums/check_in_status.dart';
import 'package:classpulse/models/check_in_record.dart';
import 'package:classpulse/services/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
    return _db.getAllRecords();
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

