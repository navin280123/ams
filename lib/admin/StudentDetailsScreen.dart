import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final String email;
  final String role;
  final String orgId;

  StudentDetailsScreen({
    required this.studentId,
    required this.email,
    required this.role,
    required this.orgId,
  });

  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  late DatabaseReference _studentRef;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _studentRef = FirebaseDatabase.instance
        .ref()
        .child('org')
        .child(widget.orgId)
        .child('students')
        .child(widget.studentId);
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    DataSnapshot snapshot = await _studentRef.child('details').get();
    Map<dynamic, dynamic>? studentDetails = snapshot.value as Map?;
    if (studentDetails != null) {
      setState(() {
        _nameController.text = studentDetails['name'] ?? '';
        _emailController.text = studentDetails['email'] ?? '';
        _mobileController.text = studentDetails['mobile'] ?? '';
        _domainController.text = studentDetails['domain'] ?? '';
        _genderController.text = studentDetails['gender'] ?? '';
      });
    }
  }

  Future<void> _updateStudentDetails() async {
    await _studentRef.child('details').update({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'domain': _domainController.text.trim(),
      'gender': _genderController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student updated successfully!')));
  }

  Future<void> _deleteStudent() async {
    await _studentRef.remove();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student deleted successfully!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateStudentDetails();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/image/login.json',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.8, // Adjust opacity as needed
              child: Card(
                elevation: 8,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildDetailRow('Name', _nameController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Email', _emailController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Mobile', _mobileController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Domain', _domainController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Gender', _genderController, _isEditing),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isEditing ? _deleteStudent : null,
                              icon: Icon(Icons.delete),
                              label: Text('Delete Student'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, TextEditingController controller, bool isEditing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: isEditing
              ? TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              controller.text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
