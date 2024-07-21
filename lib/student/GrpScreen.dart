import 'package:ams/admin/GroupDetailsScreen.dart';
import 'package:ams/student/GrpDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class Grpscreen extends StatefulWidget {
  final String email;
  final String id;
  final String role;

  Grpscreen({required this.email, required this.role, required this.id});

  @override
  _GrpscreenState createState() => _GrpscreenState();
}

class _GrpscreenState extends State<Grpscreen> {
  List<String> _studentNames = [];
  List<String> _studentId = [];
  List<String> _groupsId = [];
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _fetchStudentNames();
  }

  Future<void> _fetchStudentNames() async {
    final DatabaseReference _databaseReference =
    FirebaseDatabase.instance.ref().child('org').child(widget.id).child('students');

    DatabaseEvent event = await _databaseReference.once();
    DataSnapshot snapshot = event.snapshot; // Get DataSnapshot from DatabaseEvent

    if (snapshot.value != null) { // Check if data exists
      Map<dynamic, dynamic> students = snapshot.value as Map<dynamic, dynamic>;
      students.forEach((key, value) {
        String studentName = value['details']['name'];
        setState(() {
          _studentNames.add(studentName);
        });
        String studentId = key;
        setState(() {
          _studentId.add(studentId);
        });
      });
    }
  }

  Future<void> _fetchStudents() async {
    String stdemail = widget.email.replaceAll(RegExp(r'[.@]'), '');
    final dbRef = FirebaseDatabase.instance
        .reference()
        .child('org')
        .child(widget.id)
        .child('students')
        .child(stdemail)
        .child('groups');
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        List<Map<String, dynamic>> newStudents = [];
        data.forEach((groupId, groupValue) {
          _groupsId.add(groupId);
          final groupDetails = Map<String, dynamic>.from(groupValue['details']);
          final studentData = {
            'groupId': groupId,
            'groupName': groupDetails['groupName'],
            'groupAdmin': groupDetails['groupAdmin'],
          };
          newStudents.add(studentData);
        });
        setState(() {
          _students = newStudents;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Card(
            color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.1),
            margin: EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey, width: 1),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.primaries[index % Colors.primaries.length],
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(student['groupName']),
              subtitle: Text('Group Admin: ${student['groupAdmin']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrpDetailsScreen(
                      groupId: student['groupId'],
                      email: widget.email,
                      role: widget.role,
                      orgId: widget.id,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
