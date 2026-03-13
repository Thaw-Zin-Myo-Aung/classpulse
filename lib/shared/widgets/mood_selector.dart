import 'package:classpulse/core/theme/app_colors.dart';
import 'package:classpulse/core/theme/app_radius.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:classpulse/models/mood_option.dart';
import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const MoodSelector({
    super.key,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: MoodOption.all.map((option) {
        final bool isSelected = option.score == selectedScore;
        return _MoodTile(
          option: option,
          isSelected: isSelected,
          onTap: () => onSelected(option.score),
        );
      }).toList(),
    );
  }
}

class _MoodTile extends StatelessWidget {
  final MoodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  static final Color _transparentBorder =
      AppColors.surfaceVariant.withValues(alpha: 0);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : _transparentBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          option.emoji,
          style: AppTextStyles.titleLarge,
        ),
      ),
    );
  }
}
