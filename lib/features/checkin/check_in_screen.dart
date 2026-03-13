import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/router/app_routes.dart';
import 'package:classpulse/features/checkin/widgets/check_in_screen_body.dart';
import 'package:classpulse/models/gps_location.dart';
import 'package:classpulse/services/location_service.dart';
import 'package:classpulse/services/qr_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  final _locationService = LocationService();
  final _qrService = QRService();

  GpsLocation? _gpsLocation;
  String? _sessionId;
  int? _selectedMood;
  bool _isGpsLoading = false;
  bool _isQrScanning = false;

  static const String _studentId = '6731503088';

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _handleGetLocation() async {
    setState(() => _isGpsLoading = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _gpsLocation = loc);
    } on LocationException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not get location. Please try again.');
    } finally {
      if (mounted) setState(() => _isGpsLoading = false);
    }
  }

  Future<void> _handleScanQr() async {
    setState(() => _isQrScanning = true);
    try {
      final id = _qrService.getMockSessionId();
      if (!mounted) return;
      setState(() => _sessionId = id);
    } on QRException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Invalid QR code. Please try again.');
    } finally {
      if (mounted) setState(() => _isQrScanning = false);
    }
  }

  void _handleMoodSelected(int score) {
    setState(() => _selectedMood = score);
  }

  Future<void> _handleSubmit() async {
    if (_gpsLocation == null || _sessionId == null || _selectedMood == null) {
      _showError('Please complete all steps before submitting.');
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await context.read<CheckInNotifier>().checkIn(
          studentId: _studentId,
          sessionId: _sessionId!,
          checkInLat: _gpsLocation!.latitude,
          checkInLng: _gpsLocation!.longitude,
          previousTopic: _previousTopicController.text.trim(),
          expectedTopic: _expectedTopicController.text.trim(),
          moodBefore: _selectedMood!,
        );

    if (!mounted) return;

    final error = context.read<CheckInNotifier>().errorMessage;
    if (error != null && error.isNotEmpty) {
      _showError(error);
      return;
    }

    context.go(AppRoutes.home.path);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get _canSubmit {
    final formOk = (_previousTopicController.text.trim().isNotEmpty &&
        _expectedTopicController.text.trim().isNotEmpty);
    return _gpsLocation != null &&
        _sessionId != null &&
        _selectedMood != null &&
        formOk;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: CheckInScreenBody(
          formKey: _formKey,
          previousTopicController: _previousTopicController,
          expectedTopicController: _expectedTopicController,
          isGpsLoading: _isGpsLoading,
          isQrScanning: _isQrScanning,
          gpsLocation: _gpsLocation,
          sessionId: _sessionId,
          selectedMood: _selectedMood,
          onGetLocation: _handleGetLocation,
          onScanQr: _handleScanQr,
          onMoodSelected: _handleMoodSelected,
          onSubmit: _canSubmit ? _handleSubmit : null,
          onCancel: () => context.go(AppRoutes.home.path),
        ),
      ),
    );
  }
}
