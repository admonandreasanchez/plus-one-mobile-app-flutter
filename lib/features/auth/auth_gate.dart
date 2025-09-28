import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plusone/services/firestore_service.dart';
import 'package:plusone/features/home/home_screen.dart';
import 'package:plusone/features/auth/sign_in_screen.dart';
import 'package:plusone/features/onboarding/onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, authSnap) {
        // 1) Esperando estado de autenticación
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2) No hay usuario -> ir a Iniciar sesión
        if (!authSnap.hasData) {
          return const SignInScreen();
        }

        // 3) Hay usuario -> cargar perfil de Firestore
        return FutureBuilder<Map<String, dynamic>?>(
          future: FirestoreService().getUserProfile(),
          builder: (_, profSnap) {
            if (profSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profSnap.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error cargando perfil: ${profSnap.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            // Si data es null (p.ej. offline sin caché), tratamos como "sin animal"
            final data = profSnap.data;
            final hasAnimal = data != null && data['animal'] != null;

            return hasAnimal ? const HomeScreen() : const OnboardingScreen();
          },
        );
      },
    );
  }
}

