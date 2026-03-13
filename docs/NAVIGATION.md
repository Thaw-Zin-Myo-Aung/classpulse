# NAVIGATION.md
# ClassPulse — Navigation & Routing Contract

> **AI Instruction:** Use **GoRouter** for all navigation. No `Navigator.push()` directly.
> All route names MUST use the `AppRoutes` enum constants — never hardcode strings like `'/home'`.
> There is NO authentication flow. The app starts at `/splash` and immediately proceeds to `/home`.

---

## 1. Route Map

```
App Start
    │
    ▼
/splash  (SplashScreen)
    │  auto-navigate after 2 seconds
    ▼
/home  (HomeScreen)
    ├─── [Tap "Check In" button]  ───►  /checkin  (CheckInScreen)
    │                                        │
    │                              [Submit Pre-Class Form]
    │                                        │
    ◄──────────────────────────────────────◄  go('/home')
    │
    ├─── [Tap "Finish Class" button]  ─►  /finish  (FinishClassScreen)
    │                                        │
    │                              [Submit Post-Class Form]
    │                                        │
    ◄──────────────────────────────────────◄  go('/home')
```

---

## 2. Route Definitions

| Route Name | Path | Screen | Description |
|------------|------|--------|-------------|
| `splash` | `/splash` | `SplashScreen` | Logo + app name, auto-redirects to home after 2s |
| `home` | `/home` | `HomeScreen` | Status card, Check In / Finish Class buttons, session history list |
| `checkIn` | `/checkin` | `CheckInScreen` | GPS capture + QR scan + pre-class reflection form |
| `finish` | `/finish` | `FinishClassScreen` | QR scan + GPS capture + post-class reflection form |

---

## 3. Route Name Enum (`AppRoutes`)

> **AI Instruction:** Always reference `AppRoutes.x.path` for navigation.
> NEVER write `context.go('/home')` with a raw string. Use `context.go(AppRoutes.home.path)`.

```dart
enum AppRoutes {
  splash('/splash'),
  home('/home'),
  checkIn('/checkin'),
  finish('/finish');

  const AppRoutes(this.path);
  final String path;
}
```

---

## 4. GoRouter Configuration

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:classpulse/core/router/app_routes.dart';
import 'package:classpulse/features/splash/splash_screen.dart';
import 'package:classpulse/features/home/home_screen.dart';
import 'package:classpulse/features/checkin/check_in_screen.dart';
import 'package:classpulse/features/checkout/finish_class_screen.dart';

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
```

---

## 5. Screen Transition Behaviour

| Transition | From | To | Method | Reason |
|-----------|------|-----|--------|--------|
| Auto-redirect | `/splash` | `/home` | `context.go()` | Replaces splash in stack — back button should NOT return to splash |
| Forward | `/home` | `/checkin` | `context.go()` | Replace, not push — back should NOT return mid-flow |
| Forward | `/home` | `/finish` | `context.go()` | Replace, not push |
| Return | `/checkin` | `/home` | `context.go()` | After form submit |
| Return | `/finish` | `/home` | `context.go()` | After form submit |

> **AI Instruction:** Use `context.go()` for ALL navigation in this app.
> Do NOT use `context.push()` — we do not want a navigation stack that lets users go back mid-form.

---

## 6. Splash Screen Behaviour

```dart
// SplashScreen auto-navigates after 2 seconds
@override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) context.go(AppRoutes.home.path);
  });
}
```

- Shows: ClassPulse logo + app name centered
- Background: `AppColors.primary` (`#6D4AFF`)
- Text color: `AppColors.textOnPrimary` (white)
- No user interaction required

---

## 7. Navigation Guards (MVP Rules)

| Guard | Rule |
|-------|------|
| Check-in availability | `CheckInScreen` should only be accessible if `status == null` (no active session). Enforce in `HomeScreen` button logic, not router. |
| Finish availability | `FinishClassScreen` should only be accessible if `status == checkedIn`. Enforce in `HomeScreen` button logic, not router. |
| No back from forms | Both `/checkin` and `/finish` use `context.go()` so device back button returns to Home safely. |

---

## 8. Required pubspec.yaml Dependency

```yaml
dependencies:
  go_router: ^14.0.0
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT use `Navigator.of(context).push()` anywhere in the app.

> ⚠️ Do NOT use `context.push()` — use `context.go()` exclusively.

> ⚠️ Do NOT hardcode route strings. Always use `AppRoutes.x.path`.

> ⚠️ Do NOT add a back button or `WillPopScope` to Check-in or Finish Class screens.

> ⚠️ Do NOT create a bottom navigation bar — this app uses direct screen transitions only.
