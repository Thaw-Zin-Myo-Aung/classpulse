import 'package:classpulse/core/router/app_routes.dart';
import 'package:classpulse/features/checkin/check_in_screen.dart';
import 'package:classpulse/features/checkout/finish_class_screen.dart';
import 'package:classpulse/features/home/home_screen.dart';
import 'package:classpulse/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash.path,
  routes: [
    GoRoute(
      path: AppRoutes.splash.path,
      name: AppRoutes.splash.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home.path,
      name: AppRoutes.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkIn.path,
      name: AppRoutes.checkIn.name,
      builder: (context, state) => const CheckInScreen(),
    ),
    GoRoute(
      path: AppRoutes.finish.path,
      name: AppRoutes.finish.name,
      builder: (context, state) => const FinishClassScreen(),
    ),
  ],
);

