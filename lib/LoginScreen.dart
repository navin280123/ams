import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ForgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
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
          // Lottie animation as background
          // Lottie.asset(
          //   'assets/image/welcomebackground.json',
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Successful")));
      // Navigate to the next screen on successful login
    } catch (e) {
      print('Sign in failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Failed: ${e.toString()}")));
      // Handle sign in errors
    }
  }

  void _registerWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration Successful")));
      // Navigate to the next screen on successful registration
    } catch (e) {
      print('Registration failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration Failed: ${e.toString()}")));
      // Handle registration errors
    }
  }
}
