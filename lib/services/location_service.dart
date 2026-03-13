import 'package:classpulse/models/gps_location.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<GpsLocation> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException('Location permission denied.');
    }

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw const LocationException('Location request timed out.'),
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

