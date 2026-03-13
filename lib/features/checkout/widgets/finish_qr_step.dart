import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/shared/widgets/status_indicator.dart';
import 'package:classpulse/shared/widgets/step_section_label.dart';
import 'package:flutter/material.dart';

import '../../checkin/widgets/step_action_button.dart';

class FinishQrStep extends StatelessWidget {
  final bool isScanning;
  final String? sessionId;
  final bool isMismatch;
  final VoidCallback onScan;

  const FinishQrStep({
    super.key,
    required this.isScanning,
    required this.sessionId,
    required this.isMismatch,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = sessionId != null && sessionId!.isNotEmpty && !isMismatch;
    final message = _message(isComplete);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepSectionLabel(
          stepNumber: 'Step 1',
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

  String _message(bool isComplete) {
    if (isScanning) return 'Scanning QR…';
    if (isMismatch) return 'QR code does not match your current session.';
    if (isComplete) return 'Session ID: $sessionId ✓';
    return 'Tap to scan your class QR code';
  }
}

