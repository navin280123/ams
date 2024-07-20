import 'package:ams/admin/AdminProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Login-signin/LoginScreen.dart';
import 'GroupScreen.dart';
import 'NotificationScreen.dart';
import 'OverviewScreen.dart';
import 'QrScreen.dart';
import 'StudentScreen.dart';

class AdminDashboard extends StatefulWidget {
  final String email;
  final String id;
  final String role;

  AdminDashboard({required this.email, required this.role, required this.id});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions() => [
    GroupScreen(email: widget.email, role: widget.role, id: widget.id),
    StudentScreen(email: widget.email, role: widget.role, id: widget.id),
    NotificationScreen(email: widget.email, role: widget.role, orgId: widget.id),
    QrScreen(email: widget.email, role: widget.role, id: widget.id),
    OverviewScreen(email: widget.email, role: widget.role, id: widget.id),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',style: TextStyle(fontFamily: 'Monsteraat',fontWeight: FontWeight.w900),),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed:(){
              // Profile Setting.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminProfileScreen( orgId: widget.id)),
              );
            }
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // setting functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,

            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.person),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.qr_code),
            label: 'QR Code',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}







