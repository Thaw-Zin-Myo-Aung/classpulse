import 'package:classpulse/core/theme/app_colors.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isLoading;
  final bool isSuccess;
  final String? message;

  const StatusIndicator({
    super.key,
    required this.isLoading,
    required this.isSuccess,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && !isSuccess && (message == null || message!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final Widget leading = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 18,
            color: isSuccess ? AppColors.success : AppColors.textSecondary,
          );

    final Color textColor =
        isSuccess ? AppColors.success : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message ?? (isLoading ? 'Loading…' : ''),
              style: AppTextStyles.bodyMedium.copyWith(color: textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

