import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Controla el estado de carga

  Future<void> _signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fieldsRequired)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Registrar usuario en Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Confirmar que el usuario fue creado correctamente
      if (userCredential.user != null) {
        emailController.clear();
        passwordController.clear();

        // Mostrar diálogo de éxito
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.signupSuccessTitle),
              content: Text(AppLocalizations.of(context)!.signupSuccess),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el diálogo
                    Navigator.pushNamed(context, '/login'); // Navega al LoginPage
                  },
                  child: Text(AppLocalizations.of(context)!.goToLogin),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = AppLocalizations.of(context)!.emailAlreadyInUse;
      } else if (e.code == 'weak-password') {
        errorMessage = AppLocalizations.of(context)!.weakPassword;
      } else {
        errorMessage = AppLocalizations.of(context)!.signupError;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.signupError)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.signup),
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
                ? CircularProgressIndicator() // Indicador de carga mientras se procesa el registro
                : ElevatedButton(
              onPressed: _signUp,
              child: Text(localization.signup),
            ),
          ],
        ),
      ),
    );
  }
}
