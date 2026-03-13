import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/features/checkin/widgets/step_action_button.dart';
import 'package:classpulse/features/checkout/widgets/finish_class_form_section.dart';
import 'package:classpulse/features/checkout/widgets/finish_location_step.dart';
import 'package:classpulse/features/checkout/widgets/finish_qr_step.dart';
import 'package:classpulse/models/gps_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FinishClassScreenBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController learningController;
  final TextEditingController feedbackController;
  final bool isQrScanning;
  final bool isGpsLoading;
  final String? sessionId;
  final bool isQrMismatch;
  final GpsLocation? gpsLocation;
  final VoidCallback onScanQr;
  final VoidCallback onGetLocation;
  final VoidCallback? onSubmit;
  final VoidCallback onCancel;

  const FinishClassScreenBody({
    super.key,
    required this.formKey,
    required this.learningController,
    required this.feedbackController,
    required this.isQrScanning,
    required this.isGpsLoading,
    required this.sessionId,
    required this.isQrMismatch,
    required this.gpsLocation,
    required this.onScanQr,
    required this.onGetLocation,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CheckInNotifier>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FinishQrStep(
            isScanning: isQrScanning,
            sessionId: sessionId,
            isMismatch: isQrMismatch,
            onScan: onScanQr,
          ),
          const SizedBox(height: AppSpacing.lg),
          FinishLocationStep(
            isLoading: isGpsLoading,
            location: gpsLocation,
            onGetLocation: onGetLocation,
          ),
          const SizedBox(height: AppSpacing.lg),
          FinishClassFormSection(
            formKey: formKey,
            learningController: learningController,
            feedbackController: feedbackController,
          ),
          const SizedBox(height: AppSpacing.lg),
          StepActionButton(
            icon: Icons.flag_outlined,
            label: 'Complete Class',
            isPrimary: true,
            onPressed: notifier.isLoading ? null : onSubmit,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

