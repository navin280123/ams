import 'package:firebase_auth/firebase_auth.dart';
import 'package:ams/Login-signin/LoginScreen.dart';
import 'package:ams/student/GrpScreen.dart';
import 'package:ams/student/NotifyScreen.dart';
import 'package:ams/student/OverView.dart';
import 'package:flutter/material.dart';

class StudentDashBoard extends StatefulWidget {
  final String email;
  final String id;
  final String role;
  

  StudentDashBoard({required this.email, required this.role,required this.id});
  @override
  _StudentDashBoardState createState() => _StudentDashBoardState();
}

class _StudentDashBoardState extends State<StudentDashBoard> {
   int _selectedIndex = 0;

  List<Widget> _widgetOptions() => [
    Grpscreen(email:widget.email, role: widget.role, id: widget.id),
    Notifyscreen(email:widget.email, role: widget.role, id: widget.id),
    Overview(email:widget.email, role: widget.role, id: widget.id),
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
        title: Text('Student Dashboard',style: TextStyle(fontFamily: 'Monsteraat',fontWeight: FontWeight.w900),),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed:(){
              // Profile Setting.
            }
          ),
          
          IconButton(
            icon: Icon(Icons.qr_code),
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
            icon: Icon(Icons.notifications),
            label: 'Notifications',
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







