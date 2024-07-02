import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jopple/main.dart';
import 'package:jopple/services.dart';
import 'package:vibration/vibration.dart';
import 'Employee_Menu.dart';
import 'Employer_Menu.dart';
import 'candidate infopage.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _vibrate() async {
  bool hasVibrator = await Vibration.hasVibrator() ?? false;
  if (hasVibrator) {
    Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
  }
}

Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
    );
  } catch (e) {
    print('Error logging out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging out. Please try again.')),
    );
  }
}

FirestoreService firestoreService = FirestoreService();
String? displayName = current_user_displayName;

class MenuSplashScreen extends StatefulWidget {
  @override
  _MenuSplashScreenState createState() => _MenuSplashScreenState();
}

class _MenuSplashScreenState extends State<MenuSplashScreen>
    with SingleTickerProviderStateMixin {

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/jp.png',
                  width: 120,
                  height: 162,
                ),
                SizedBox(height: 30),
                Text(
                  'Welcome to Jopple!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize
                                .min,
                            children: [
                              SizedBox(
                                  height: 20),
                              Text(
                                'Are you sure you want to proceed\ncreating your account as Job seeker?',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Note : You can't change your account\nas job recruiter once you chose yes",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight
                                        .bold, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                  height: 20),
                              // Add some space between text and buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton
                                        .styleFrom(
                                      backgroundColor: Colors
                                          .green[500],
                                      padding: EdgeInsets
                                          .symmetric(
                                          horizontal: 30,
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius
                                            .circular(
                                            10),
                                      ),
                                    ),
                                    onPressed: () {
                                      _vibrate();
                                      firestoreService.createNewUserEmployee(context);
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight: FontWeight
                                              .bold),
                                    ),
                                  ),
                                  SizedBox(
                                      width: 10),
                                  // Add some space between buttons
                                  ElevatedButton(
                                    style: ElevatedButton
                                        .styleFrom(
                                      backgroundColor: Colors
                                          .red[500],
                                      padding: EdgeInsets
                                          .symmetric(
                                          horizontal: 30,
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius
                                            .circular(
                                            10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator
                                          .of(
                                          context)
                                          .pop(
                                          false); // Close the dialog and return false
                                    },
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight: FontWeight
                                              .bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.orange[400],
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.black, // Set border color here
                          width: 4.0,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 220,
                        height: 70,
                        color: Colors.orange[400],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Image.asset(
                              'images/emp.png',
                              width: 75,
                            ),
                            SizedBox(width: 20),
                            Text(
                              "Looking for job?",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "(or)",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'cour'),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize
                                .min,
                            children: [
                              SizedBox(
                                  height: 20),
                              Text(
                                'Are you sure you want to proceed\ncreating your account as Job recruiter?',
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Note : You can't change your account\nas job seeker once you chose yes",
                                style: TextStyle(
                                  color: Colors.red,
                                    fontWeight: FontWeight
                                        .bold, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                  height: 20),
                              // Add some space between text and buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton
                                        .styleFrom(
                                      backgroundColor: Colors
                                          .green[500],
                                      padding: EdgeInsets
                                          .symmetric(
                                          horizontal: 30,
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius
                                            .circular(
                                            10),
                                      ),
                                    ),
                                    onPressed: () {
                                      _vibrate();
                                      firestoreService.createNewUserEmployer(context);
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight: FontWeight
                                              .bold),
                                    ),
                                  ),
                                  SizedBox(
                                      width: 10),
                                  // Add some space between buttons
                                  ElevatedButton(
                                    style: ElevatedButton
                                        .styleFrom(
                                      backgroundColor: Colors
                                          .red[500],
                                      padding: EdgeInsets
                                          .symmetric(
                                          horizontal: 30,
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius
                                            .circular(
                                            10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator
                                          .of(
                                          context)
                                          .pop(
                                          false); // Close the dialog and return false
                                    },
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight: FontWeight
                                              .bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.orange[400],
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.black, // Set border color here
                          width: 4.0,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 220,
                        height: 70,
                        color: Colors.orange[400],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'images/hire.png',
                              width: 75, // Adjust width as needed
                            ),
                            SizedBox(width: 20),
                            Text(
                              "Need to Hire?",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}