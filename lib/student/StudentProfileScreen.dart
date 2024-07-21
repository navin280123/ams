import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class StudentProfileScreen extends StatefulWidget {
  final String orgId;
  final String email;

  StudentProfileScreen({
    required this.orgId,
    required this.email
  });

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  late DatabaseReference _adminRef;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    //remove @ and  . from string for id of the student.
    String stdemail = widget.email.replaceAll(RegExp(r'[.@]'), '');
    _adminRef = FirebaseDatabase.instance
        .ref()
        .child('org')
        .child(widget.orgId)
        .child('students')
        .child(stdemail)
        .child('details');
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    DataSnapshot snapshot = await _adminRef.get();
    Map<dynamic, dynamic>? adminDetails = snapshot.value as Map?;
    if (adminDetails != null) {
      setState(() {
        _nameController.text = adminDetails['name'] ?? '';
        _emailController.text = adminDetails['email'] ?? '';
        _mobileController.text = adminDetails['mobile'] ?? '';
        _genderController.text = adminDetails['gender'] ?? '';
        _domainController.text = adminDetails['domain'] ?? '';
      });
    }
  }

  Future<void> _updateAdminDetails() async {
    await _adminRef.update({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'gender': _genderController.text.trim(),
      'domain': _domainController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student Profile'),
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateAdminDetails();
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
                        _buildDetailRow('Gender', _genderController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Domain', _domainController, _isEditing),
                        SizedBox(height: 10),
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
