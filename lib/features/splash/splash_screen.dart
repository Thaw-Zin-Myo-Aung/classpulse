import 'package:classpulse/core/router/app_routes.dart';
import 'package:classpulse/core/theme/app_colors.dart';
import 'package:classpulse/core/theme/app_spacing.dart';
import 'package:classpulse/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go(AppRoutes.home.path);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school_rounded,
                size: 72,
                color: AppColors.textOnPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'ClassPulse',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Smart Class Check-in',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
