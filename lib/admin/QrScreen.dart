import 'package:flutter/material.dart';

class QrScreen extends StatelessWidget {
  final String email;
  final String id;
  final String role;

  QrScreen({required this.email, required this.role, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: $email'),
            Text('Role: $role'),
            Text('ID: $id'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add group functionality
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
