import 'package:classpulse/core/enums/check_in_status.dart';
import 'package:classpulse/core/theme/app_colors.dart';
import 'package:classpulse/core/theme/app_radius.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final CheckInStatus? status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final _StatusCardConfig config = _StatusCardConfig.fromStatus(status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(config.icon, style: AppTextStyles.titleLarge),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.title, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(config.subtitle, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCardConfig {
  final String icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const _StatusCardConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });

  factory _StatusCardConfig.fromStatus(CheckInStatus? status) {
    final dateText = _todayText();

    switch (status) {
      case null:
        return _StatusCardConfig(
          icon: '🟣',
          title: 'Ready to Check In',
          subtitle: dateText,
          backgroundColor: AppColors.surface,
        );
      case CheckInStatus.checkedIn:
        return _StatusCardConfig(
          icon: '⏳',
          title: 'Class In Progress',
          subtitle: dateText,
          backgroundColor: AppColors.primaryLight,
        );
      case CheckInStatus.completed:
        return _StatusCardConfig(
          icon: '✅',
          title: 'Class Completed!',
          subtitle: dateText,
          backgroundColor: AppColors.success.withValues(alpha: 0.12),
        );
    }
  }

  static String _todayText() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    return 'Today, $day ${months[now.month - 1]} ${now.year}';
  }
}

