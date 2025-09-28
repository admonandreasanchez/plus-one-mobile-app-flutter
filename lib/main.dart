// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:plusone/l10n/app_localizations.dart';
import 'package:plusone/config/routes.dart';
import 'package:plusone/features/auth/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializa Firebase una sola vez
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔐 Comportamiento de sesión:
  // - En Web: no persistir (cierra sesión al cerrar pestaña).
  // - En Android/iOS: cerramos sesión al iniciar la app (simula "logout al cerrar app").
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.NONE);
  } else {
    await FirebaseAuth.instance.signOut();
  }

  runApp(const PlusOneApp());
}

class PlusOneApp extends StatelessWidget {
  const PlusOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlusOne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),

      // 🌎 Localización
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final l in supported) {
          if (l.languageCode == locale.languageCode) return l;
        }
        return const Locale('en');
      },

      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const AuthGate(),
    );
  }
}
