import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';

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
  bool _showButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lottie animation as background
          Lottie.asset(
            'assets/image/welcomebackground.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Welcome to AMS\n\n',
                              textStyle: TextStyle(
                                fontFamily: 'Monsteraat',
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              speed: Duration(milliseconds: 100),
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
                                ),
                                speed: Duration(milliseconds: 100),
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
                                ),
                                speed: Duration(milliseconds: 100),
                              ),
                            ],
                            isRepeatingAnimation: false,
                            onFinished: () {
                              setState(() {
                                _showButton = true;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  Spacer(),
                  if (_showButton)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
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
            ),
          ),
        ],
      ),
    );
  }
}
