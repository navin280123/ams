import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group QR Codes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QrScreen(email: 'test@example.com', id: 'sampleId', role: 'user'),
    );
  }
}

class QrScreen extends StatefulWidget {
  final String email;
  final String id;
  final String role;

  QrScreen({required this.email, required this.role, required this.id});

  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  bool isLoading = true;
  Map<String, dynamic> groupDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    final snapshot = await databaseReference.child('org/${widget.id}/groups').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        groupDetails = Map<String, dynamic>.from(data);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _generateQrCode(String groupId) async {
    final qrData = 'RandomValue-${Random().nextInt(10000)}';
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    await databaseReference.child('org/${widget.id}/groups/$groupId/qr/$formattedDate').set({
      'qrData': qrData,
      'timestamp': now.toIso8601String(),
    });

    setState(() {
      groupDetails[groupId]['qr'] = {formattedDate: {'qrData': qrData, 'timestamp': now.toIso8601String()}};
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR code generated and saved to Firebase!')));
  }

  Future<void> _saveQrCode(String qrData) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;
        final painter = QrPainter.withQr(
          qr: qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );

        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/qr_code.png';
        final picData = await painter.toImageData(300);

        if (picData != null) {
          final buffer = picData.buffer.asUint8List();
          final image = img.decodeImage(buffer)!;
          final file = File(filePath);
          await file.writeAsBytes(img.encodePng(image));

          await GallerySaver.saveImage(file.path);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR code saved to gallery!')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving QR code: $e')));
    }
  }

  void _shareQrCode(String qrData) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;
        final painter = QrPainter.withQr(
          qr: qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );

        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/qr_code.png';
        final picData = await painter.toImageData(300);

        if (picData != null) {
          final buffer = picData.buffer.asUint8List();
          final image = img.decodeImage(buffer)!;
          final file = File(filePath);
          await file.writeAsBytes(img.encodePng(image));

          Share.shareFiles([file.path], text: 'Here is my QR code!');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing QR code: $e')));
    }
  }

  void _viewQrCode(String qrData) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QrCodeFullScreen(qrData: qrData),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: groupDetails.length,
        itemBuilder: (context, index) {
          final groupId = groupDetails.keys.elementAt(index);
          final group = groupDetails[groupId];
          final details = group['details'];
          final qrData = group['qr']?[formattedDate]?['qrData'];

          return Card(
            margin: EdgeInsets.all(8.0),
            color: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.group, size: 30, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Group: ${details['groupName']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 30, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Admin: ${details['groupAdmin']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 30, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Admin Phone: ${details['adminPhone']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 16),
                  qrData == null
                      ? ElevatedButton(
                    onPressed: () => _generateQrCode(groupId),
                    child: Text('Generate QR Code'),
                  )
                      : Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        size: 150,
                      ),
                      ElevatedButton(
                        onPressed: () => _viewQrCode(qrData),
                        child: Text('View QR Code'),
                      ),
                      ElevatedButton(
                        onPressed: () => _saveQrCode(qrData),
                        child: Text('Save QR Code to Gallery'),
                      ),
                      ElevatedButton(
                        onPressed: () => _shareQrCode(qrData),
                        child: Text('Share QR Code'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QrCodeFullScreen extends StatelessWidget {
  final String qrData;

  QrCodeFullScreen({required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Full Screen'),
      ),
      body: Center(
        child: QrImageView(
          data: qrData,
          size: 300,
        ),
      ),
    );
  }
}
