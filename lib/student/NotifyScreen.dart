import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotifyScreen extends StatefulWidget {
  final String orgId;
  final String email;
  final String role;

  NotifyScreen({ required this.email, required this.role,required this.orgId,});

  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    String stdemail = widget.email.replaceAll(RegExp(r'[.@]'), '');
    final dbRef = FirebaseDatabase.instance
        .ref()
        .child('org')
        .child(widget.orgId)
        .child('notifications');
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        List<Map<String, dynamic>> newNotifications = [];
        data.forEach((key, value) {
          final notificationData = Map<String, dynamic>.from(value);
          newNotifications.add({
            'id': key,
            ...notificationData,
          });
        });
        setState(() {
          _notifications.clear();
          _notifications.addAll(newNotifications);
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey, width: 1),
            ),
            child: ListTile(
              title: Text(notification['subject']),
              subtitle: Text(notification['details']),

            ),
          );
        },
      ),

    );
  }
}
