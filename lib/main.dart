import 'package:ams/AdminDashBoard.dart';
import 'package:ams/StudentDashBoard.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'RoleSelectionScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AttendanceManagementSystem());
}

class AttendanceManagementSystem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      String cleanedEmail = email.replaceAll(RegExp(r'[.@]'), '');

      DatabaseReference roleRef = FirebaseDatabase.instance.ref().child('role').child(cleanedEmail);
      DatabaseEvent roleEvent = await roleRef.once();
      DataSnapshot roleSnapshot = roleEvent.snapshot;

      if (roleSnapshot.exists) {
        Map<dynamic, dynamic> roleData = roleSnapshot.value as Map<dynamic, dynamic>;
        String roleValue = roleData['role'];
        String orgValue = roleValue.length == 8 ? roleValue : roleValue.substring(0, 8);

        DatabaseReference orgRef = FirebaseDatabase.instance.ref().child('org').child(orgValue).child('details');
        DatabaseEvent orgEvent = await orgRef.once();
        DataSnapshot orgSnapshot = orgEvent.snapshot;

        if (orgSnapshot.exists) {
          Map<dynamic, dynamic> orgData = orgSnapshot.value as Map<dynamic, dynamic>;
          String orgEmail = orgData['email'];

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Login Successful")));

          // Navigate to the appropriate screen based on the role
          if (roleValue.length == 8) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard(email: orgEmail, role: "Admin",id: orgValue)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentDashBoard(email: orgEmail, role: "Student",id: orgValue)),
            );
          }
        }
      }
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
                            setState(() {
                              _showSecondText = true;
                            });
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
