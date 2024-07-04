import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import 'ForgotPasswordScreen.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;

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
          Lottie.asset(
            'assets/image/welcomebackground.json',
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? 'LOGIN' : 'REGISTER',
                          style: TextStyle(fontFamily: 'Monsteraat',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(style: TextStyle(fontFamily: 'Monsteraat',fontWeight: FontWeight.bold,fontSize: 19),
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
                                style: TextStyle(fontSize: 15,
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
                                style: TextStyle(fontSize: 15,
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
                        if (!isLogin) ...[
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'Confirm Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                        ] else ...[
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
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
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Add your login or registration code here
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
                            text: 'By signing up, you agree to our ',style: TextStyle(fontSize: 15,fontFamily: 'Monsteraat',fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: 'Terms, ',
                                style: TextStyle(color: Colors.blue,fontFamily: 'Monsteraat',),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    //terms and condition section
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
        ],
      ),
    );
  }
}