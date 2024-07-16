import 'package:flutter/material.dart';

class StudentDashBoard extends StatelessWidget {
  final String email;
  final String id;
  final String role;

  StudentDashBoard({required this.email, required this.role,required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: $email'),
            Text('Role: $role'),
            Text('Role: $id'),
          ],
        ),
      ),
    );
  }
}
