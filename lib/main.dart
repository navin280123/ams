import 'package:ams/admin/AdminDashBoard.dart';
import 'package:ams/student/StudentDashBoard.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ams/Login-signin/RoleSelectionScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // Choose the appropriate provider based on your platform
    androidProvider: AndroidProvider.safetyNet,
    // ... other providers for iOS, web, etc.
  );
  runApp(AttendanceManagementSystem());
}

class AttendanceManagementSystem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showSecondText = false;
  bool _showThirdText = false;
  bool _showLottie = false;
  bool _showButton = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user !=null) {
      String email = user.email ?? '';
      String cleanedEmail = email.replaceAll(RegExp(r'[.@]'), '');

      DatabaseReference roleRef = FirebaseDatabase.instance.ref().child('role');
      DatabaseEvent roleEvent = await roleRef.child(cleanedEmail).child('role').once();
      DataSnapshot roleSnapshot = roleEvent.snapshot;

      if (roleSnapshot.exists) {
        String roleValue = roleSnapshot.value as String;

        if (roleValue.length == 8) {
          // Admin flow
          DatabaseReference orgRef = FirebaseDatabase.instance.ref().child('org').child(roleValue).child('details');
          DatabaseEvent orgEvent = await orgRef.once();
          DataSnapshot orgSnapshot = orgEvent.snapshot;

          if (orgSnapshot.exists) {
            Map<dynamic, dynamic> orgData = orgSnapshot.value as Map<dynamic, dynamic>;
            String orgEmail = orgData['email'];

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful")));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard(email: orgEmail, role: "Admin", id: roleValue)),
            );
          }
        } else {
          // Student flow
          String studentId = roleValue.substring(0, 8);
          DatabaseReference studentRef = FirebaseDatabase.instance.ref()
              .child('org')
              .child(studentId)
              .child('students')
              .child(cleanedEmail)
              .child('details');
          DatabaseEvent studentEvent = await studentRef.once();
          DataSnapshot studentSnapshot = studentEvent.snapshot;

          if (studentSnapshot.exists) {
            Map<dynamic, dynamic> studentData = studentSnapshot.value as Map<dynamic, dynamic>;
            String studentEmail = studentData['email'];

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful")));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentDashBoard(email: studentEmail, role: "Student", id: studentId)),
            );
          }
        }
      }
    } else {
      setState(() {
        _isUserLoggedIn = false;
        // _showSecondText = true; // Show the second text if user is not logged in
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
          ),
          if (_showLottie)
          // Lottie animation as background
            Lottie.asset(
              'assets/image/welcomebackground.json',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  setState(() {
                    _showButton = true;
                  });
                });
              },
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  if (!_showLottie)
                    Column(
                      children: [
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Welcome to AMS\n\n',
                              textStyle: TextStyle(
                                fontFamily: 'Monsteraat',
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              speed: Duration(milliseconds: 70),
                            ),
                          ],
                          isRepeatingAnimation: false,
                          onFinished: () {
                            if (_isUserLoggedIn) {
                              setState(() {
                                _showLottie = true;
                              });
                            } else {
                              setState(() {
                                _showSecondText = true;
                              });
                            }
                          },
                        ),
                        if (_showSecondText)
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Attendance Management System\nCreated to record and manage attendance.\n\n\n',
                                textAlign: TextAlign.center,
                                textStyle: TextStyle(
                                  fontFamily: 'Monsteraat',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                speed: Duration(milliseconds: 50),
                              ),
                            ],
                            isRepeatingAnimation: false,
                            onFinished: () {
                              setState(() {
                                _showThirdText = true;
                              });
                            },
                          ),
                        if (_showThirdText)
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Unicorn is an app where users can leverage their social network to create, discover, share, and monetize events or services.\n\n\n\n',
                                textAlign: TextAlign.center,
                                textStyle: TextStyle(
                                  fontFamily: 'Monsteraat',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                speed: Duration(milliseconds: 50),
                              ),
                            ],
                            isRepeatingAnimation: false,
                            onFinished: () {
                              setState(() {
                                _showLottie = true;
                              });
                            },
                          ),
                      ],
                    ),
                  if (_showLottie)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Welcome to AMS\n\n',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Monsteraat',
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (!_isUserLoggedIn) ...[
                                Text(
                                  'Attendance Management System\nCreated to record and manage attendance.\n\n\n',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Monsteraat',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Unicorn is an app where users can leverage their social network to create, discover, share, and monetize events or services.\n\n\n\n',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Monsteraat',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_showButton)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                              );
                            },
                            child: Text('Get Started'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
