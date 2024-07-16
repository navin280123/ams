import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

class StudentScreen extends StatefulWidget {
  final String email;
  final String id;
  final String role;

  StudentScreen({required this.email, required this.role, required this.id});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _domainController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedCountryCode = '+91'; // Default country code

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

  String _generateRandomPassword(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  Future<void> _saveStudentDetails() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _generateRandomPassword(12);
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final dbRef = FirebaseDatabase.instance
            .reference()
            .child('org')
            .child(widget.id)
            .child('students')
            .child(email.replaceAll('.', '').replaceAll('@', ''))
            .child('details');

        await dbRef.set({
          'name': _nameController.text,
          'domain': _domainController.text,
          'mobile': '$_selectedCountryCode-${_mobileController.text}',
          'email': email,
          'gender': _selectedGender,
        });

        final roleRef = FirebaseDatabase.instance
            .reference()
            .child('role')
            .child(email.replaceAll('.', '').replaceAll('@', ''));

        await roleRef.set({
          'role': widget.id + 's',
        });

        _nameController.clear();
        _domainController.clear();
        _mobileController.clear();
        _emailController.clear();
        setState(() {
          _selectedGender = 'Male';
        });

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        print("Error: $e");
      }
    }
  }

  void _showAddStudentDialog() {
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
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _domainController,
                        decoration: InputDecoration(
                          labelText: 'Domain',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a domain';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: 'Mobile No',
                          border: OutlineInputBorder(),
                        ),
                        initialCountryCode: 'IN',
                        onChanged: (phone) {
                          _selectedCountryCode = phone.countryCode;
                          _mobileController.text = phone.number;
                        },
                        validator: (value) {
                          if (value == null || value.number.isEmpty) {
                            return 'Please enter a mobile number';
                          } else if (!RegExp(r'^[0-9]+$').hasMatch(value.number)) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: <String>['Male', 'Female', 'Other']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveStudentDetails,
                        child: Text('Save'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _downloadExcelTemplate,
                        child: Text('Download Excel Template'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _importExcelFile,
                        child: Text('Import Excel File'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _downloadExcelTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1']; // Or create a new sheet and add it

    // Set cell values and styles (using the code you provided)
    CellStyle cellStyle = CellStyle(
        backgroundColorHex: ExcelColor.amber600,
        fontFamily: getFontFamily(FontFamily.Calibri));
    cellStyle.underline = Underline.Single;
    var cell1 = sheet.cell(CellIndex.indexByString('A1'));
    cell1.value = TextCellValue('Name');
    var cell2 = sheet.cell(CellIndex.indexByString('B1'));
    cell2.value = TextCellValue('Domain');
    var cell3 = sheet.cell(CellIndex.indexByString('C1'));
    cell3.value = TextCellValue('Mobile');
    var cell4 = sheet.cell(CellIndex.indexByString('D1'));
    cell4.value = TextCellValue('Email');
    var cell5 = sheet.cell(CellIndex.indexByString('E1'));
    cell5.value = TextCellValue("Gender");
    cell1.cellStyle = cellStyle;
    cell2.cellStyle = cellStyle;
    cell3.cellStyle = cellStyle;
    cell4.cellStyle = cellStyle;
    cell5.cellStyle = cellStyle;
    // ... (rest of your cell value setting code)

    // Save the Excel file
    final fileBytes = excel.save();

    // Get the app's documents directory
    final directory = await getExternalStorageDirectory();
    final downloadPath = directory!.path;
    final fileName = "example.xlsx";
    // Create a file in the documents directory
    final file = File('$downloadPath/$fileName');
    await file.writeAsBytes(fileBytes!, flush: true);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("File Saved in" + file.path)));
    Navigator.pop(context);
    print('Excel file saved to: $file');
  }


  Future<void> _importExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) {
        print('Error: No file selected.');
        return;
      }

      PlatformFile file = result.files.first;
      Uint8List? fileBytes;

      if (file.bytes != null) {
        fileBytes = file.bytes;
      } else if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      }

      if (fileBytes == null) {
        print('Error: No bytes found in the selected file.');
        return;
      }

      var excel = Excel.decodeBytes(fileBytes);
      if (excel == null) {
        print('Error: Unable to decode Excel file.');
        return;
      }

      for (var table in excel.tables.keys) {
        print('Processing table: $table');
        var sheet = excel.tables[table];
        if (sheet == null) {
          print('Error: No sheet found for table: $table');
          continue;
        }

        for (int i = 1; i < sheet.rows.length; i++) {
          var row = sheet.rows[i];
          if (row == null) {
            print('Error: No row data found at index: $i');
            continue;
          }

          String name = row[0]?.value?.toString() ?? '';
          String domain = row[1]?.value?.toString() ?? '';
          String mobile = row[2]?.value?.toString() ?? '';
          String email = row[3]?.value?.toString() ?? '';
          String gender = row[4]?.value?.toString() ?? '';

          print('Row $i: $name, $domain, $mobile, $email, $gender');

          if (name.isEmpty ||
              domain.isEmpty ||
              mobile.isEmpty ||
              email.isEmpty ||
              gender.isEmpty) {
            print('Invalid data in row $i, skipping...');
            continue;
          }

          String password = _generateRandomPassword(12);
          try {
            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            final dbRef = FirebaseDatabase.instance
                .reference()
                .child('org')
                .child(widget.id)
                .child('students')
                .child(email.replaceAll('.', '').replaceAll('@', ''))
                .child('details');

            await dbRef.set({
              'name': name,
              'domain': domain,
              'mobile': mobile,
              'email': email,
              'gender': gender,
            });

            final roleRef = FirebaseDatabase.instance
                .reference()
                .child('role')
                .child(email.replaceAll('.', '').replaceAll('@', ''));

            await roleRef.set({
              'role': widget.id + 's',
            });

            print('User $email registered successfully.');
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('User $email registered successfully.')));
            Navigator.pop(context);
          } on FirebaseAuthException catch (e) {
            print('FirebaseAuthException for $email: $e');
          } catch (e) {
            print('General exception for $email: $e');
          }
        }

      }
    } catch (e) {
      print('An error occurred: $e');
    }
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
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
