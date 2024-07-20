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


class QrScreen extends StatefulWidget {
  final String email;
  final String id;
  final String role;

  QrScreen({required this.email, required this.role, required this.id});

  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  String? qrData;
  bool isLoading = true;
  bool isQrAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkQrAvailability();
  }

  Future<void> _checkQrAvailability() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final snapshot = await databaseReference.child('org/${widget.id}/qr/$formattedDate').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        qrData = data['qrData'];
        isQrAvailable = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _generateQrCode() {
    setState(() {
      qrData = 'RandomValue-${Random().nextInt(10000)}';
    });
    _saveQrDetailsToFirebase(qrData!);
  }

  Future<void> _saveQrCode() async {
    if (qrData == null) return;

    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData!,
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

  void _shareQrCode() async {
    if (qrData == null) return;

    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData!,
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

  Future<void> _saveQrDetailsToFirebase(String qrData) async {
    final databaseReference = FirebaseDatabase.instance.reference();
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    await databaseReference.child('org/${widget.id}/qr/$formattedDate').set({
      'qrData': qrData,
      'timestamp': now.toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR details saved to Firebase!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (qrData != null)
              QrImageView(
                data: qrData!,
                size: 300,
              ),
            Spacer(),
            ElevatedButton(
              onPressed: isQrAvailable ? null : _generateQrCode,
              child: Text('Generate QR Code'),
            ),
            ElevatedButton(
              onPressed: _saveQrCode,
              child: Text('Save QR Code to Gallery'),
            ),
            ElevatedButton(
              onPressed: _shareQrCode,
              child: Text('Share QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}
