import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/router/app_routes.dart';
import 'package:classpulse/features/checkout/widgets/finish_class_screen_body.dart';
import 'package:classpulse/models/gps_location.dart';
import 'package:classpulse/services/location_service.dart';
import 'package:classpulse/services/qr_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learningController = TextEditingController();
  final _feedbackController = TextEditingController();

  final _locationService = LocationService();
  final _qrService = QRService();

  String? _sessionId;
  bool _isQrScanning = false;
  bool _qrMismatch = false;

  GpsLocation? _gpsLocation;
  bool _isGpsLoading = false;

  @override
  void dispose() {
    _learningController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleScanQr() async {
    setState(() => _isQrScanning = true);
    try {
      final scanned = _qrService.getMockSessionId();
      if (!mounted) return;

      final current = context.read<CheckInNotifier>().currentRecord;
      final expectedSessionId = current?.sessionId;

      final mismatch =
          expectedSessionId != null && scanned.trim() != expectedSessionId;

      setState(() {
        _sessionId = scanned;
        _qrMismatch = mismatch;
      });

      if (mismatch) {
        _showError('QR code does not match your current session.');
      }
    } on QRException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Invalid QR code. Please try again.');
    } finally {
      if (mounted) setState(() => _isQrScanning = false);
    }
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

  Future<void> _handleSubmit() async {
    final current = context.read<CheckInNotifier>().currentRecord;
    if (current == null) {
      _showError('No active session found.');
      return;
    }

    if (_sessionId == null || _qrMismatch || _gpsLocation == null) {
      _showError('Please complete all steps before submitting.');
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await context.read<CheckInNotifier>().checkOut(
          checkOutLat: _gpsLocation!.latitude,
          checkOutLng: _gpsLocation!.longitude,
          learningSummary: _learningController.text.trim(),
          classFeedback: _feedbackController.text.trim(),
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
    final formOk = (_learningController.text.trim().isNotEmpty &&
        _feedbackController.text.trim().isNotEmpty);

    return _sessionId != null &&
        !_qrMismatch &&
        _gpsLocation != null &&
        formOk;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish Class'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: FinishClassScreenBody(
          formKey: _formKey,
          learningController: _learningController,
          feedbackController: _feedbackController,
          isQrScanning: _isQrScanning,
          isGpsLoading: _isGpsLoading,
          sessionId: _sessionId,
          isQrMismatch: _qrMismatch,
          gpsLocation: _gpsLocation,
          onScanQr: _handleScanQr,
          onGetLocation: _handleGetLocation,
          onSubmit: _canSubmit ? _handleSubmit : null,
          onCancel: () => context.go(AppRoutes.home.path),
        ),
      ),
    );
  }
}
