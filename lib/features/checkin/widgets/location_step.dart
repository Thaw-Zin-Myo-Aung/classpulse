import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/models/gps_location.dart';
import 'package:classpulse/shared/widgets/status_indicator.dart';
import 'package:classpulse/shared/widgets/step_section_label.dart';
import 'package:flutter/material.dart';

import 'step_action_button.dart';

class LocationStep extends StatelessWidget {
  final bool isLoading;
  final GpsLocation? location;
  final VoidCallback onGetLocation;

  const LocationStep({
    super.key,
    required this.isLoading,
    required this.location,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComplete = location != null;
    final String message = _message(isComplete);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepSectionLabel(
          stepNumber: 'Step 1',
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
