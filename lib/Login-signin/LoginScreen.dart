import 'dart:math';
import 'package:ams/admin/AdminDashBoard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'ForgotPasswordScreen.dart';
import '../student/StudentDashBoard.dart';

final FirebaseDatabase _database = FirebaseDatabase.instance;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool _isLoading = false; // Flag for loading animation
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
                            isLogin ? 'LOGIN' : 'REGISTER',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            isLogin
                                ? 'Welcome back, kindly sign in and continue your journey with us'
                                : 'Create an account to get started',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isLogin = true;
                                  });
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    decoration: isLogin
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isLogin = false;
                                  });
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: isLogin ? Colors.grey : Colors.black,
                                    decoration: !isLogin
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 900),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(child: child, opacity: animation);
                            },
                            child: isLogin
                                ? _buildLoginForm()
                                : _buildRegisterForm(),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _isLoading = true; // Show loading animation
                                });
                                if (isLogin) {
                                  _signInWithEmailAndPassword();
                                } else {
                                  _registerWithEmailAndPassword();
                                }
                              }
                            },
                            child: Text(isLogin ? 'Login' : 'Register'),
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
          if (_isLoading) // Show loading animation on top
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Lottie.asset(
                    'assets/image/loading.json', // Replace with your loading animation asset
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: ValueKey<bool>(isLogin),
      children: [
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
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: ValueKey<bool>(!isLogin),
      children: [
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
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: 'Confirm Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
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
      }
    } catch (e) {
      print('Sign in failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Failed: ${e.toString()}")));
      // Handle sign in errors
    } finally {
      setState(() {
        _isLoading = false; // Hide loading animation
      });
    }
  }

  void _registerWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String email = _emailController.text.trim();
      int randomNumber = _generateRandomNumber();
      String sanitizedEmail = email.replaceAll('@', '').replaceAll('.', '');

      DatabaseReference roleRef = _database.ref().child('role').child(sanitizedEmail);
      DatabaseReference orgRef = _database.ref().child('org').child(randomNumber.toString());

      await roleRef.set({
        'role': randomNumber,
      });

      await orgRef.child('details').set({
        'email': email,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration Successful")));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard(email: email, role: "Admin", id: randomNumber.toString())),
      );
    } catch (e) {
      print('Registration failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration Failed: ${e.toString()}")));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading animation
      });
    }
  }

  int _generateRandomNumber() {
    Random random = Random();
    return 10000000 + random.nextInt(90000000);
  }
}
