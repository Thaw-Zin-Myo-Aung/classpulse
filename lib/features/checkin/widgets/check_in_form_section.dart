import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/features/checkin/widgets/primary_text_field.dart';
import 'package:classpulse/shared/widgets/mood_selector.dart';
import 'package:flutter/material.dart';

class CheckInFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController previousTopicController;
  final TextEditingController expectedTopicController;
  final int? selectedMood;
  final ValueChanged<int> onMoodSelected;

  const CheckInFormSection({
    super.key,
    required this.formKey,
    required this.previousTopicController,
    required this.expectedTopicController,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryTextField(
            controller: previousTopicController,
            label: 'Previous Topic',
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryTextField(
            controller: expectedTopicController,
            label: 'Expected Topic',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.md),
          MoodSelector(
            selectedScore: selectedMood,
            onSelected: onMoodSelected,
          ),
        ],
      ),
    );
  }
}

