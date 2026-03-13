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

