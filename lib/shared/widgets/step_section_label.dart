import 'package:classpulse/core/theme/app_colors.dart';
import 'package:classpulse/core/theme/app_radius.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StepSectionLabel extends StatelessWidget {
  final String stepNumber;
  final String title;
  final bool isComplete;

  const StepSectionLabel({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            stepNumber,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(title, style: AppTextStyles.titleMedium),
        ),
        if (isComplete)
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
      ],
    );
  }
}
