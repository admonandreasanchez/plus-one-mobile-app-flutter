import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Estado de carga
  int _failedAttempts = 0; // Contador de intentos fallidos
  bool _isBlocked = false; // Estado de bloqueo
  int _blockTime = 3;  // Tiempo inicial de bloqueo en minutos
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> _login() async {
    if (_isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.accountBlocked(_blockTime)
          ),
        ),
      );
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fieldsRequired)),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidEmail)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _failedAttempts = 0;
      _blockTime = 3;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccess)),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      _failedAttempts++;

      if (_failedAttempts >= 3) {
        _isBlocked = true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.accountBlocked(_blockTime)),
          ),
        );

        Future.delayed(Duration(minutes: _blockTime), () {
          if (mounted) {
            setState(() {
              _isBlocked = false;
              _blockTime = _blockTime < 10 ? _blockTime + 2 : 10;
            });
          }
        });

        return;
      }

      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = AppLocalizations.of(context)!.userNotFound;
      } else if (e.code == 'wrong-password') {
        errorMessage = AppLocalizations.of(context)!.wrongPassword;
      } else {
        errorMessage = AppLocalizations.of(context)!.loginError;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.login),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: localization.email,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: localization.password,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: Text(localization.login),
            ),
            SizedBox(height: 10), // Espaciado entre los botones
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password'); // Ruta para la pantalla de recuperación
              },
              child: Text(localization.forgotPassword),
            ),
          ],
        ),
      ),
    );
  }
}
