import 'package:ams/admin/GroupDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class GroupScreen extends StatefulWidget {
  final String email;
  final String id;
  final String role;

  GroupScreen({required this.email, required this.role, required this.id});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupAdminController = TextEditingController();
  final TextEditingController _groupAdminMobileController = TextEditingController();
  List<String> _studentNames = [];
  List<String> _studentId = [];
  List<String> _selectedStudents = [];
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
    final dbRef = FirebaseDatabase.instance
        .reference()
        .child('org')
        .child(widget.id)
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

  void _addStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Students'),
              content: Container(
                width: double.minPositive,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _studentNames.length,
                  itemBuilder: (BuildContext context, int index) {
                    final isSelected = _selectedStudents.contains(_studentNames[index]);
                    return ListTile(
                      title: Text(_studentNames[index]),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _selectedStudents.add(_studentNames[index]);
                            } else {
                              _selectedStudents.remove(_studentNames[index]);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Text('Selected Students: ${_selectedStudents.length}'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    print(_selectedStudents);
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.add),
                ),
                // Group name
                TextFormField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a group name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // Group admin
                TextFormField(
                  controller: _groupAdminController,
                  decoration: InputDecoration(
                    labelText: 'Group Admin',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a group admin name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // Group admin phone
                IntlPhoneField(
                  controller: _groupAdminMobileController,
                  decoration: InputDecoration(
                    labelText: 'Group Admin Phone',
                    border: OutlineInputBorder(),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    _groupAdminMobileController.text = phone.completeNumber;
                  },
                  validator: (PhoneNumber? value) {
                    if (value == null || value.completeNumber.isEmpty) {
                      return 'Please enter a group admin phone number';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value.completeNumber)) {
                      return 'Please enter a valid group admin phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _addStudentDialog, // Add student button action
                      child: Text('Add Student'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cancel button action
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _saveGroupDetails, // Save button action
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveGroupDetails() {
    String groupName = _groupNameController.text.trim();
    String location = _locationController.text.trim();
    String groupAdmin = _groupAdminController.text.trim();
    String groupAdminPhone = _groupAdminMobileController.text.trim();

    if (_validateInputs()) {
      DatabaseReference groupRef = FirebaseDatabase.instance.ref()
          .child('org')
          .child(widget.id) // Assuming 'widget.id' holds the organization ID
          .child('groups')
          .push(); // Generate a unique key for the group

      // Save group details
      groupRef.child('details').set({
        'groupName': groupName,
        'location': location,
        'groupAdmin': groupAdmin,
        'adminPhone': groupAdminPhone,
      });

      for (int i = 0; i < _selectedStudents.length; i++) {
        groupRef.child('students').child(_studentId[_studentNames.indexOf(_selectedStudents[i])]).set({
          'name': _selectedStudents[i],
        });
      }

      // Clear controllers, show success message, and close dialog
      _groupNameController.clear();
      _locationController.clear();
      _groupAdminController.clear();
      _groupAdminMobileController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Group saved successfully!")));
      Navigator.of(context).pop();
    }
  }

  bool _validateInputs() {
    // Implement your validation logic here
    // Example: Validate all form fields
    if (_groupNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _groupAdminController.text.isEmpty ||
        _groupAdminMobileController.text.isEmpty) {
      // Show validation errors if any field is empty
      setState(() {
        // Update UI if necessary
      });
      return false;
    }
    return true;
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
                    builder: (context) => GroupDetailsScreen(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
