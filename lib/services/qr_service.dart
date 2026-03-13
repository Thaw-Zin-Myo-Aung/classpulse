class QRService {
  String parseQRResult(String rawValue) {
    const prefix = 'CLASSPULSE-';
    if (!rawValue.startsWith(prefix)) {
      throw const QRException(
        'Invalid QR code. Not a ClassPulse session QR.',
      );
    }

    final sessionId = rawValue.substring(prefix.length).trim();
    if (sessionId.isEmpty) {
      throw const QRException('QR code contains no session ID.');
    }

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

