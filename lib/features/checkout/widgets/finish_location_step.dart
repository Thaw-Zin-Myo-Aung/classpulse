import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/models/gps_location.dart';
import 'package:classpulse/shared/widgets/status_indicator.dart';
import 'package:classpulse/shared/widgets/step_section_label.dart';
import 'package:flutter/material.dart';

import '../../checkin/widgets/step_action_button.dart';

class FinishLocationStep extends StatelessWidget {
  final bool isLoading;
  final GpsLocation? location;
  final VoidCallback onGetLocation;

  const FinishLocationStep({
    super.key,
    required this.isLoading,
    required this.location,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = location != null;
    final message = _message(isComplete);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepSectionLabel(
          stepNumber: 'Step 2',
          title: 'Location',
          isComplete: isComplete,
        ),
        const SizedBox(height: AppSpacing.sm),
        StepActionButton(
          icon: Icons.my_location_rounded,
          label: 'Get My Location',
          onPressed: onGetLocation,
        ),
        StatusIndicator(
          isLoading: isLoading,
          isSuccess: isComplete,
          message: message,
        ),
      ],
    );
  }

  String _message(bool isComplete) {
    if (isLoading) return 'Getting location…';
    if (isComplete) {
      return 'Lat: ${location!.latitude.toStringAsFixed(2)} | Lng: ${location!.longitude.toStringAsFixed(2)}';
    }
    return 'Tap to capture your current location';
  }
}

