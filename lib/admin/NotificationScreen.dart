import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationScreen extends StatefulWidget {
  final String orgId;
  final String email;
  final String role;

  NotificationScreen({ required this.email, required this.role,required this.orgId,});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
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

  Future<void> _saveNotification() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final notificationData = {
        'date': now.toIso8601String(),
        'subject': _subjectController.text.trim(),
        'details': _detailsController.text.trim(),
      };
      final dbRef = FirebaseDatabase.instance
          .ref()
          .child('org')
          .child(widget.orgId)
          .child('notifications');
      await dbRef.push().set(notificationData);
      _subjectController.clear();
      _detailsController.clear();
      Navigator.pop(context);
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final dbRef = FirebaseDatabase.instance
        .ref()
        .child('org')
        .child(widget.orgId)
        .child('notifications')
        .child(notificationId);
    await dbRef.remove();
  }

  void _showAddNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notification_add, color: Colors.blue),
              SizedBox(width: 8),
              Text('Add Notification'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.add_alert_sharp, size: 40),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subject),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      labelText: 'Details',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.details),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter details';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveNotification,
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteNotification(notification['id']);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNotificationDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
