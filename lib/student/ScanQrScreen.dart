import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScanQrScreen extends StatefulWidget {
  final String orgId;
  final String email;

  ScanQrScreen({
    required this.orgId,
    required this.email,
  });

  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData.code;
      });

      if (result != null) {
        await _processQrCode(result!);
      }
    });
  }



  Future<void> _processQrCode(String scannedData) async {
    try {
      // Remove '@' and '.' from email
      String sanitizedEmail = widget.email.replaceAll('@', '').replaceAll('.', '');
      print('Sanitized Email: $sanitizedEmail');

      // Access Firebase Realtime Database
      DatabaseReference database = FirebaseDatabase.instance.ref();

      // Fetch groups under the organization
      DataSnapshot groupsSnapshot = await database
          .child('org')
          .child(widget.orgId)
          .child('groups')
          .get(); // Use .get() here instead of .once()

      if (groupsSnapshot.exists) {
        print('Total Groups: ${groupsSnapshot.children.length}');

        // Today's date in the required format
        DateTime now = DateTime.now();

        // Format the date to "yyyy-M-d"
        String todayDate = DateFormat('yyyy-M-d').format(now);

        print('Today\'s Date: $todayDate'); // Example output: "2024-7-21"

        bool foundMatchingQR = false;

        // Iterate through each group
        for (DataSnapshot groupSnapshot in groupsSnapshot.children) {
          print('Checking Group ID: ${groupSnapshot.key}');

          // Access QR data for today's date
          DataSnapshot qrSnapshot = await database
              .child('org')
              .child(widget.orgId)
              .child('groups')
              .child(groupSnapshot.key!)
              .child('qr')
              .child(todayDate)
              .get(); // Use .get() here instead of .once()
          print(qrSnapshot.ref.path);
          if (qrSnapshot.exists) {
            print('QR Data Exists for Group ${groupSnapshot.key}: ${qrSnapshot.child('qrData').value}');

            if (qrSnapshot.child('qrData').value == scannedData) {
              // Matching QR data found
              String groupId = groupSnapshot.key!;
              print('Matching QR Data Found in Group: $groupId');

              // Update attendance under the group
              DatabaseReference attendanceRef = database
                  .child('org')
                  .child(widget.orgId)
                  .child('groups')
                  .child(groupId)
                  .child('attendance')
                  .child(todayDate);

              await attendanceRef.child(sanitizedEmail).set('present');

              print('Attendance Updated for Group: $groupId');

              // Update student's attendance record
              DatabaseReference studentRef = database
                  .child('org')
                  .child(widget.orgId)
                  .child('students')
                  .child(sanitizedEmail)
                  .child('groups')
                  .child(groupId)
                  .child('attendance')
                  .child(todayDate);

              await studentRef.set({
                'status': 'present',
              });

              print('Student Attendance Updated for Group: $groupId');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Attendance marked successfully')),
              );

              foundMatchingQR = true;
              break;
            }
          } else {
            print('QR Data Does Not Exist for Group ${groupSnapshot.key}');
          }
        }

        if (!foundMatchingQR) {
          // If no matching QR data found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid QR code or QR data not found')),
          );
        }
      } else {
        print('No groups found for the organization');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No groups found for the organization')),
        );
      }
    } catch (e) {
      // Handle any errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code Screen'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Scan result: $result')
                  : Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }
}
