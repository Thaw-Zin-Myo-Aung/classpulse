import 'package:classpulse/core/enums/check_in_status.dart';
import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/router/app_routes.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:classpulse/features/home/widgets/session_history_item.dart';
import 'package:classpulse/features/home/widgets/status_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CheckInNotifier>();
    final CheckInStatus? status = notifier.currentStatus;
    final history = notifier.sessionHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text('ClassPulse', style: AppTextStyles.titleLarge),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatusCard(status: status),
            const SizedBox(height: AppSpacing.lg),
            _ActionButton(status: status),
            const SizedBox(height: AppSpacing.lg),
            Text('Recent Sessions', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No sessions yet',
                        style: AppTextStyles.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        return SessionHistoryItem(record: history[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final CheckInStatus? status;

  const _ActionButton({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return ElevatedButton.icon(
        onPressed: () => context.go(AppRoutes.checkIn.path),
        icon: const Icon(Icons.check_circle_outline_rounded),
        label: const Text('Check In'),
      );
    }

    if (status == CheckInStatus.checkedIn) {
      return ElevatedButton.icon(
        onPressed: () => context.go(AppRoutes.finish.path),
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Finish Class'),
      );
    }

    return const SizedBox.shrink();
  }
}
