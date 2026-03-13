import 'package:classpulse/core/theme/app_colors.dart';
import 'package:classpulse/core/theme/app_radius.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CheckOutCard extends StatelessWidget {
  final String courseName;
  final String statusLabel;
  final VoidCallback? onCheckOut;

  const CheckOutCard({
    super.key,
    required this.courseName,
    required this.statusLabel,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.book_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(courseName, style: AppTextStyles.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(statusLabel, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onCheckOut,
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }
}
