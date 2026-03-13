import 'package:classpulse/core/providers/check_in_notifier.dart';
import 'package:classpulse/core/router/app_router.dart';
import 'package:classpulse/core/theme/app_theme.dart';
import 'package:classpulse/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ClassPulseApp());
}

class ClassPulseApp extends StatelessWidget {
  const ClassPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckInNotifier()..loadHistory()),
      ],
      child: MaterialApp.router(
        title: 'ClassPulse',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
