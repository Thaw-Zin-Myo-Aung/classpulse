import 'package:cloud_firestore/cloud_firestore.dart';

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
      throw const SessionException('Could not load session. Check connection.');
    }
  }
}

class SessionException implements Exception {
  final String message;
  const SessionException(this.message);

  @override
  String toString() => 'SessionException: $message';
}

