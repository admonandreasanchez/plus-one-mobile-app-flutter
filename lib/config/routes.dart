import 'package:flutter/material.dart';
import 'package:plusone/features/auth/sign_in_screen.dart';
import 'package:plusone/features/auth/sign_up_screen.dart';
import 'package:plusone/features/home/home_screen.dart';
import 'package:plusone/features/onboarding/onboarding_screen.dart';
import 'package:plusone/features/timer/shower_timer_screen.dart';
import 'package:plusone/features/mission/mission_intro_screen.dart';

class AppRoutes {
  static const signIn      = '/sign-in';
  static const signUp      = '/sign-up';
  static const home        = '/home';
  static const onboarding  = '/onboarding';
  static const showerTimer = '/shower-timer';
  static const missionIntro = '/mission-intro';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case showerTimer:
        return MaterialPageRoute(builder: (_) => const ShowerTimerScreen());
      case missionIntro:
        return MaterialPageRoute(builder: (_) => const MissionIntroScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
    }
  }
}
