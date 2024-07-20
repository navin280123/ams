import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OverviewScreen extends StatelessWidget {
  final String email;
  final String id;
  final String role;

  OverviewScreen({required this.email, required this.role, required this.id});

  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  Future<Map<String, int>> getCounts() async {
    final studentsSnapshot = await databaseReference.child('org/$id/students').once();
    final groupsSnapshot = await databaseReference.child('org/$id/groups').once();

    int studentCount = (studentsSnapshot.snapshot.value as Map?)?.keys.length ?? 0;
    int groupCount = (groupsSnapshot.snapshot.value as Map?)?.keys.length ?? 0;

    return {
      'students': studentCount,
      'groups': groupCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: $email'),
            Text('Role: $role'),
            Text('ID: $id'),
          ],
        ),
=======
      body: FutureBuilder<Map<String, int>>(
        future: getCounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final counts = snapshot.data ?? {'students': 0, 'groups': 0};

          return Column(
            children: [
              Card(
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Students',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            '${counts['students']}',
                            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Groups',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            '${counts['groups']}',
                            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Email: $email'),
                      Text('Role: $role'),
                      Text('ID: $id'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
>>>>>>> Stashed changes
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
