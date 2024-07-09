import 'package:ams/AdminDashBoard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'ForgotPasswordScreen.dart';
import 'StudentDashBoard.dart';

final FirebaseDatabase _database = FirebaseDatabase.instance;

class StudentLoginScreen extends StatefulWidget {
  @override
  _StudentLoginScreenState createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Lottie.asset(
            'assets/image/login.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Welcome back, kindly sign in and continue your journey with us',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value ?? '')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text('Forgot password?'),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _signInWithEmailAndPassword();
                              }
                            },
                            child: Text('Login'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Or Connect With'),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                  icon: Image.asset('assets/image/facebook.png'),
                                  onPressed: () {
                                    _launchURL('https://www.facebook.com/');
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                  icon: Image.asset('assets/image/instagram.png'),
                                  onPressed: () {
                                    _launchURL('https://www.instagram.com/');
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                  icon: Image.asset('assets/image/twitter.png'),
                                  onPressed: () {
                                    _launchURL('https://www.twitter.com/');
                                  },
                                ),
                              ),
                            ],
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'By signing up, you agree to our ',
                              children: [
                                TextSpan(
                                  text: 'Terms, ',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // terms and condition section
                                    },
                                ),
                                TextSpan(
                                  text: 'Data Policy ',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // data policy section
                                    },
                                ),
                                TextSpan(
                                  text: 'and ',
                                ),
                                TextSpan(
                                  text: 'Cookie Policy.',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // cookie policy section
                                    },
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
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
    } catch (e) {
      print('Sign in failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Failed: ${e.toString()}")));
      // Handle sign in errors
    }
  }
}
