import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String email;
  final String role;
  final String orgId;

  GroupDetailsScreen({
    required this.groupId,
    required this.email,
    required this.role,
    required this.orgId,
  });

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupAdminController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupAdminMobileController = TextEditingController();
  late DatabaseReference _groupRef;
  bool _isEditing = false;
  List<Map<String, dynamic>> _students = [];
  List<String> _selectedStudentIds = [];

  @override
  void initState() {
    super.initState();
    _groupRef = FirebaseDatabase.instance
        .ref()
        .child('org')
        .child(widget.orgId)
        .child('groups')
        .child(widget.groupId);
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    DataSnapshot snapshot = await _groupRef.child('details').get();
    Map<dynamic, dynamic>? groupDetails = snapshot.value as Map?;
    if (groupDetails != null) {
      setState(() {
        _groupNameController.text = groupDetails['groupName'] ?? '';
        _groupAdminController.text = groupDetails['groupAdmin'] ?? '';
        _locationController.text = groupDetails['location'] ?? '';
        _groupAdminMobileController.text = groupDetails['adminPhone'] ?? '';
      });
    }
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    DatabaseReference studentRef = FirebaseDatabase.instance
        .ref()
        .child('org')
        .child(widget.orgId)
        .child('students');
    DataSnapshot snapshot = await studentRef.get();
    Map<dynamic, dynamic>? students = snapshot.value as Map?;
    if (students != null) {
      List<Map<String, dynamic>> newStudents = [];
      students.forEach((key, value) {
        newStudents.add({
          'id': key,
          'name': value['details']['name'] ?? 'Unknown',
        });
      });
      setState(() {
        _students = newStudents;
      });
    }
    _fetchSelectedStudents();
  }

  Future<void> _fetchSelectedStudents() async {
    DatabaseReference groupStudentsRef = _groupRef.child('students');
    DataSnapshot snapshot = await groupStudentsRef.get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> selectedStudents = snapshot.value as Map<dynamic, dynamic>;
      List<String> selectedIds = selectedStudents.keys.cast<String>().toList();
      setState(() {
        _selectedStudentIds = selectedIds;
      });
    }
  }

  Future<void> _updateGroupDetails() async {
    await _groupRef.child('details').update({
      'groupName': _groupNameController.text.trim(),
      'groupAdmin': _groupAdminController.text.trim(),
      'location': _locationController.text.trim(),
      'adminPhone': _groupAdminMobileController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group updated successfully!')));
  }

  Future<void> _deleteGroup() async {
    await _groupRef.remove();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group deleted successfully!')));
    Navigator.of(context).pop();
  }

  void _showStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Students'),
              content: Container(
                width: double.minPositive,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _students.length,
                  itemBuilder: (BuildContext context, int index) {
                    final student = _students[index];
                    final isSelected = _selectedStudentIds.contains(student['id']);
                    return ListTile(
                      title: Text(student['name']),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _selectedStudentIds.add(student['id']);
                            } else {
                              _selectedStudentIds.remove(student['id']);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Text('Selected Students: ${_selectedStudentIds.length}'),
                TextButton(
                  onPressed: () {
                    _saveSelectedStudents();
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveSelectedStudents() async {
    DatabaseReference groupStudentsRef = _groupRef.child('students');
    await groupStudentsRef.remove();
    for (String studentId in _selectedStudentIds) {
      await groupStudentsRef.child(studentId).set({
        'name': _students.firstWhere((student) => student['id'] == studentId)['name'],
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Students updated successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateGroupDetails();
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
              opacity: 0.8,// Adjust opacity as needed
              child: Card(
                elevation: 8,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildDetailRow('Group Name', _groupNameController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Group Admin', _groupAdminController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Location', _locationController, _isEditing),
                        SizedBox(height: 10),
                        _buildDetailRow('Admin Phone', _groupAdminMobileController, _isEditing),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isEditing ? null : _showStudentDialog,
                              icon: Icon(Icons.group),
                              label: Text('View Students'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isEditing ? _deleteGroup : null,
                              icon: Icon(Icons.delete),
                              label: Text('Delete Group'),
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
