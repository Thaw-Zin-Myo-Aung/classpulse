import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/features/checkin/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';

class FinishClassFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController learningController;
  final TextEditingController feedbackController;

  const FinishClassFormSection({
    super.key,
    required this.formKey,
    required this.learningController,
    required this.feedbackController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryTextField(
            controller: learningController,
            label: 'What I learned',
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryTextField(
            controller: feedbackController,
            label: 'Class Feedback',
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

