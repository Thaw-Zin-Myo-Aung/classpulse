import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/features/checkin/widgets/check_in_form_section.dart';
import 'package:classpulse/features/checkin/widgets/location_step.dart';
import 'package:classpulse/features/checkin/widgets/qr_step.dart';
import 'package:classpulse/features/checkin/widgets/step_action_button.dart';
import 'package:classpulse/models/gps_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckInScreenBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController previousTopicController;
  final TextEditingController expectedTopicController;
  final bool isGpsLoading;
  final bool isQrScanning;
  final GpsLocation? gpsLocation;
  final String? sessionId;
  final int? selectedMood;
  final VoidCallback onGetLocation;
  final VoidCallback onScanQr;
  final ValueChanged<int> onMoodSelected;
  final VoidCallback? onSubmit;
  final VoidCallback onCancel;

  const CheckInScreenBody({
    super.key,
    required this.formKey,
    required this.previousTopicController,
    required this.expectedTopicController,
    required this.isGpsLoading,
    required this.isQrScanning,
    required this.gpsLocation,
    required this.sessionId,
    required this.selectedMood,
    required this.onGetLocation,
    required this.onScanQr,
    required this.onMoodSelected,
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
          LocationStep(
            isLoading: isGpsLoading,
            location: gpsLocation,
            onGetLocation: onGetLocation,
          ),
          const SizedBox(height: AppSpacing.lg),
          QrStep(
            isScanning: isQrScanning,
            sessionId: sessionId,
            onScan: onScanQr,
          ),
          const SizedBox(height: AppSpacing.lg),
          CheckInFormSection(
            formKey: formKey,
            previousTopicController: previousTopicController,
            expectedTopicController: expectedTopicController,
            selectedMood: selectedMood,
            onMoodSelected: onMoodSelected,
          ),
          const SizedBox(height: AppSpacing.lg),
          StepActionButton(
            icon: Icons.check_circle_outline_rounded,
            label: 'Submit Check In',
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
