import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/shared/widgets/status_indicator.dart';
import 'package:classpulse/shared/widgets/step_section_label.dart';
import 'package:flutter/material.dart';

import 'step_action_button.dart';

class QrStep extends StatelessWidget {
  final bool isScanning;
  final String? sessionId;
  final VoidCallback onScan;

  const QrStep({
    super.key,
    required this.isScanning,
    required this.sessionId,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComplete = sessionId != null && sessionId!.isNotEmpty;
    final String message = isScanning
        ? 'Scanning QR…'
        : isComplete
            ? 'Session ID: $sessionId ✓'
            : 'Tap to scan your class QR code';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepSectionLabel(
          stepNumber: 'Step 2',
          title: 'QR Code',
          isComplete: isComplete,
        ),
        const SizedBox(height: AppSpacing.sm),
        StepActionButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan QR Code',
          onPressed: onScan,
        ),
        StatusIndicator(
          isLoading: isScanning,
          isSuccess: isComplete,
          message: message,
        ),
      ],
    );
  }
}
