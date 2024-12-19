import 'package:flutter/material.dart';

class GuestExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore as Guest"),
      ),
      body: Center(
        child: Text("Welcome, Guest! Explore the app."),
      ),
    );
  }
}
