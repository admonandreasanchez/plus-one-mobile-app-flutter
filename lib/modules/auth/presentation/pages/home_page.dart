import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:plus_one/core/routes/routes.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.homeTitle),
        actions: user != null
            ? [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ]
            : null,
      ),
      body: Center(
        child: user != null
            ? _authenticatedContent(context, localization, user)
            : _unauthenticatedContent(context, localization),
      ),
    );
  }

  Widget _unauthenticatedContent(BuildContext context, AppLocalizations localization) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localization.welcomeMessage,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.login);
          },
          child: Text(localization.login),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.signup);
          },
          child: Text(localization.signup),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.guestExplore);
          },
          child: Text(localization.exploreAsGuest),
        ),
      ],
    );
  }

  Widget _authenticatedContent(BuildContext context, AppLocalizations localization, User user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${localization.greeting}, ${user.email}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _logout(context),
          child: Text(localization.logout),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }
}
