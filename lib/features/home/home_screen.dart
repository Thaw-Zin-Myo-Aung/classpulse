import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/router/app_routes.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:classpulse/features/home/widgets/check_in_card.dart';
import 'package:classpulse/features/home/widgets/check_out_card.dart';
import 'package:classpulse/features/home/widgets/session_history_item.dart';
import 'package:classpulse/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _courseName = 'Loading...';
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _loadCourseName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInNotifier>().loadHistory();
    });
  }

  Future<void> _loadCourseName() async {
    try {
      final data = await _sessionService.getSession('MAD-W07-2026');
      final name = (data['courseName'] as String?)?.trim();
      if (!mounted) return;
      setState(
        () => _courseName = (name == null || name.isEmpty)
            ? 'Mobile App Dev'
            : name,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _courseName = 'Mobile App Dev');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CheckInNotifier>();
    final currentRecord = notifier.currentRecord;
    final history = notifier.sessionHistory;

    void onCheckIn() => context.go(AppRoutes.checkIn.path);

    void onFinish() => context.go(AppRoutes.finish.path);

    final VoidCallback? onCheckOut = currentRecord != null ? onFinish : null;

    final String statusLabel = onCheckOut == null
        ? 'Check in first to enable'
        : 'Class in progress';

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
            CheckInCard(
              courseName: _courseName,
              dateLabel: _todayLabel(),
              onCheckIn: onCheckIn,
            ),
            const SizedBox(height: AppSpacing.md),
            CheckOutCard(
              courseName: _courseName,
              statusLabel: statusLabel,
              onCheckOut: onCheckOut,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Previous Sessions', style: AppTextStyles.titleMedium),
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

  String _todayLabel() {
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
