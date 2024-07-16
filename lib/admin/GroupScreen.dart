
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
  final TextEditingController _groupAdminMobileController =
  TextEditingController();
  List<String> _randomStudentNames = [
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Frank',
    'Grace',
    'Henry',
    'Ivy',
    'Jack'
  ];
  List<String> _selectedStudents = [];
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final dbRef = FirebaseDatabase.instance
        .reference()
        .child('org')
        .child(widget.id)
        .child('students');
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        List<Map<String, dynamic>> newStudents = [];
        data.forEach((key, value) {
          final studentData = Map<String, dynamic>.from(value['details']);
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
                  itemCount: _randomStudentNames.length,
                  itemBuilder: (BuildContext context, int index) {
                    final isSelected = _selectedStudents.contains(_randomStudentNames[index]);
                    return ListTile(
                      title: Text(_randomStudentNames[index]),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _selectedStudents.add(_randomStudentNames[index]);
                            } else {
                              _selectedStudents.remove(_randomStudentNames[index]);
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
                  child: Icon(Icons.person),
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
    // Implement your save logic here
    // For example:
    String groupName = _groupNameController.text;
    String location = _locationController.text;
    String groupAdmin = _groupAdminController.text;
    String groupAdminPhone = _groupAdminMobileController.text;

    // Validate and save data
    if (_validateInputs()) {
      // Save data to database or perform necessary actions
      print('Group Name: $groupName');
      print('Location: $location');
      print('Group Admin: $groupAdmin');
      print('Group Admin Phone: $groupAdminPhone');

      // Clear controllers after saving
      _groupNameController.clear();
      _locationController.clear();
      _groupAdminController.clear();
      _groupAdminMobileController.clear();

      // Close dialog
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
              title: Text(student['name']),
              subtitle: Text(student['email']),
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

