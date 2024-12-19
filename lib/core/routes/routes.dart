import 'package:flutter/material.dart';
import 'package:plus_one/modules/auth/presentation/pages/login_page.dart';
import 'package:plus_one/modules/auth/presentation/pages/signup_page.dart';
import 'package:plus_one/modules/auth/presentation/pages/home_page.dart';
import 'package:plus_one/modules/auth/presentation/pages/guest_explore_screen.dart';
import 'package:plus_one/modules/auth/presentation/pages/forgot_password_page.dart';

class AppRoutes {
  // Nombres de las rutas
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String guestExplore = '/guestExplore';

  // Mapa de rutas
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => LoginPage(),
    signup: (context) => SignUpPage(),
    home: (context) => HomePage(),
    guestExplore: (context) => GuestExploreScreen(),
    '/forgot-password': (context) => ForgotPasswordPage(),

  };

  // Ruta no encontrada
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Ruta no encontrada')),
        body: Center(
          child: Text(
            'La ruta ${settings.name} no está definida.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
