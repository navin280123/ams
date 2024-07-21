import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';

class GrpDetailsScreen extends StatefulWidget {
  final String groupId;
  final String email;
  final String role;
  final String orgId;

  GrpDetailsScreen({
    required this.groupId,
    required this.email,
    required this.role,
    required this.orgId,
  });

  @override
  _GrpDetailsScreenState createState() => _GrpDetailsScreenState();
}

class _GrpDetailsScreenState extends State<GrpDetailsScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupAdminController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupAdminMobileController = TextEditingController();
  late DatabaseReference _groupRef;
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
                        onChanged: null, // No interaction allowed
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Text('Selected Students: ${_selectedStudentIds.length}'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
        backgroundColor: Colors.lightBlueAccent,
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
                        _buildDetailRow('Group Name', _groupNameController, false),
                        SizedBox(height: 10),
                        _buildDetailRow('Group Admin', _groupAdminController, false),
                        SizedBox(height: 10),
                        _buildDetailRow('Location', _locationController, false),
                        SizedBox(height: 10),
                        _buildDetailRow('Admin Phone', _groupAdminMobileController, false),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showStudentDialog,
                          icon: Icon(Icons.group),
                          label: Text('View Students'),
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
          child: Padding(
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
