import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class AdminProfileScreen extends StatefulWidget {
  final String orgId;

  AdminProfileScreen({
    required this.orgId,
  });

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  late DatabaseReference _adminRef;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _adminRef = FirebaseDatabase.instance
        .ref()
        .child('org')
        .child(widget.orgId)
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
        _addressController.text = adminDetails['address'] ?? '';
        _companyController.text = adminDetails['company'] ?? '';
      });
    }
  }

  Future<void> _updateAdminDetails() async {
    await _adminRef.update({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'gender': _genderController.text.trim(),
      'address': _addressController.text.trim(),
      'company': _companyController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Admin Profile'),
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
                        _buildDetailRow('Address', _addressController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Company Name', _companyController, _isEditing),
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
