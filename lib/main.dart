import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jopple/Employee_Menu.dart';
import 'package:jopple/Employer_Menu.dart';
import 'package:jopple/rough.dart';
import 'package:jopple/services.dart';
import 'package:lottie/lottie.dart';
import 'Account_declaration_page.dart';
import 'Employer_JobId_Choose.dart';
import 'paragraphs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:soundpool/soundpool.dart';

String? current_user_uid;
String? current_user_mail;
String? current_user_displayName;
late String uid;
FirestoreService firestoreService = FirestoreService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC3vPC8amIza1B85WAps5bng6mTVA4mvu8",
      appId: "1:186179923089:android:7be14af082e7e11fe6a330",
      messagingSenderId: "186179923089",
      projectId: "jopple",
      authDomain: "jopple.firebaseapp.com",
      androidClientId: "186179923089-e2dr0caec00hdcl6071c8j52d9mn7v3l.apps.googleusercontent.com"
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  late final String text;
  late final Duration speed;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Soundpool pool;
  int soundId = 0;
  int streamId = 0;

  @override
  void initState() {
    super.initState();
    initializeSound();
    startAnimation();
    delayedNavigation(context);
  }

  void initializeSound() async {
    try {
      pool = await Soundpool.fromOptions(options: SoundpoolOptions(streamType: StreamType.notification));
      ByteData soundData = await rootBundle.load("sounds/type.mp3");
      int? soundIdResult = await pool.load(soundData);
      soundId = soundIdResult;
      playSound(); // Call playSound only if soundId is successfully loaded
        } catch (e) {
      print("Error initializing sound: $e");
    }
  }

  Future<void> playSound() async {
    if (soundId != 0) {
      streamId = await pool.play(soundId);
    }
  }

  void startAnimation() {
    Timer(Duration(milliseconds: 100), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    pool.release();
    super.dispose();
  }

  void delayedNavigation(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 700), // Adjust animation duration as needed
          pageBuilder: (_, __, ___) => LoginOrRegisterPage(),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 1.0), // Start position of the slide (from right to left)
                end: Offset.zero, // End position of the slide (to center)
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 100, width: 100, child: Image.asset('images/jp.png')),
          SizedBox(height: 40.0),
          Text('Jopple',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'was',
              letterSpacing: 4.0,
              color: Colors.white,
              fontSize: 30,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  _LoginOrRegisterPageState createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    });
  }

  Future<void> _vibrate() async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Colors.transparent.withOpacity(0.1);
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: SafeArea(
        child: Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 65.0, bottom: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: width,
                      height: 230, // Adjust the height according to your needs
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                        Image.asset(
                        'images/jp1.png',
                      ),
                          Image.asset(
                            'images/jp2.png',
                          ),
                          Image.asset(
                            'images/jp3.png',
                          ),
                          Image.asset(
                            'images/jp4.png',
                          ),
                          Image.asset(
                            'images/jp5.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 17.0),
                    child: Column(
                      children: [
                        Container(
                          height: 45,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              _vibrate();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return RegisterPage();
                                  }));
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateColor.resolveWith((states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors
                                      .green; // Change to your desired hover color
                                }
                                return Colors.black; // Default button color
                              }),
                              foregroundColor:
                              MaterialStateProperty.all(Colors.blueGrey[900]),
                              textStyle:
                              MaterialStateProperty.all(const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              )),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "For new users",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18), // Spacer
                  Padding(
                    padding: const EdgeInsets.only(top: 17.0),
                    child: Column(
                      children: [
                        Container(
                          height: 45,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              _vibrate();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return LoginPage();
                                  }));
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateColor.resolveWith((states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors
                                      .green; // Change to your desired hover color
                                }
                                return Colors.black; // Default button color
                              }),
                              foregroundColor:
                              MaterialStateProperty.all(Colors.blueGrey[900]),
                              textStyle:
                              MaterialStateProperty.all(const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              )),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "For existing users",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 21)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                      ),
                      width: width,
                      child: Column(
                        children: <Widget>[
                          EnhancedText(
                            text: "✔️  Job Search: Easily find and apply for respective jobs.",
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0,
                            color: Colors.blue,
                            textAlign: TextAlign.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          EnhancedText(
                            text: "✔️  Hiring: Showcase your company and attract talent.",
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0,
                            color: Colors.green,
                            textAlign: TextAlign.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          EnhancedText(
                            text: "✔️  Engagement: Streamline interaction with employers.",
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0,
                            color: Colors.orange,
                            textAlign: TextAlign.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              Container(
                width: 100,
                child: ElevatedButton(onPressed: () {
                  _vibrate();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return InfoPage();
                      }));
                },
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateColor.resolveWith((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors
                            .green; // Change to your desired hover color
                      }
                      return Colors.teal; // Default button color
                    }),
                    foregroundColor:
                    MaterialStateProperty.all(Colors.blueGrey[900]),
                    textStyle:
                    MaterialStateProperty.all(const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    )),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10)),
                  ),
                  child: Text(
                  "About",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Image.asset(
                        'images/job mini.png', // Adjust the BoxFit as needed
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    List<String> paragraphs = Paragraphs.getParagraphs();
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text(
          'About Jopple',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'cour',
              fontSize: 28,
              color: Colors.teal),
        ),centerTitle: true,
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.only(top:10.0),
        child: AutoScrollingScrollView(paragraphs),
      )),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var phone_no = "";
  String formatted_phone_val = "";
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  var reg_state = 0;
  final List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];
  late GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  void handleGoogleSignIn() async {
    await FirebaseAuth.instance.signOut();
    try {
      // Initialize GoogleSignIn
      _googleSignIn = GoogleSignIn(scopes: scopes);

      // Listen for changes in the current user
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
        setState(() {
          _currentUser = account;
        });
      });

      // Attempt silent sign-in
      await _googleSignIn.signInSilently();

      // Sign out the current user
      await _googleSignIn.signOut();

      // Handle sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;
        // Update ID's
        await firestoreService.updateEmployeeIds();
        await firestoreService.updateEmployerIds();
        if (firebaseUser != null) {
          // Update the state with user information
          setState(() {
            current_user_uid = userCredential.user!.uid;
            current_user_mail = userCredential.user!.email;
            current_user_displayName = userCredential.user!.displayName;
            uid = "${current_user_mail} - ${current_user_uid}";
          });
          print("************************************");
          print(current_user_uid);
          print(current_user_mail);
          print(current_user_displayName);
          print("***********************************&");
          Future<bool> doesEmployeeExist() async =>
              await FirebaseFirestore.instance.collection('User_Employee').doc(uid).get().then((doc) => doc.exists);
          String extractBeforeSecondHyphen(String input) {
            List<String> parts = input.split(' - ');
            if (parts.length > 2) {
              return parts.sublist(0, 2).join(' - ');
            } else {
              return input;
            }
          }
          Future<bool> doesEmployerExist() async {
            String prefix = extractBeforeSecondHyphen(uid);
            CollectionReference employersCollection = FirebaseFirestore.instance.collection('User_Employer');
            QuerySnapshot querySnapshot = await employersCollection.where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix).get();
            return querySnapshot.docs.any((doc) => doc.id.startsWith(prefix));
          }
          Future<bool> doMultipleEmployersExist(String uid) async {
            String prefix = extractBeforeSecondHyphen(uid);
            CollectionReference employersCollection = FirebaseFirestore.instance.collection('User_Employer');
            QuerySnapshot querySnapshot = await employersCollection.where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix).get();
            int count = querySnapshot.docs.where((doc) => doc.id.startsWith(prefix)).length;
            return count > 1;
          }
          if (await doesEmployeeExist()) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmployeeMenuPage()),
            );
          } else if (await doesEmployerExist()) {
            print("Is there multiple documents? - "
                "${await doMultipleEmployersExist(extractBeforeSecondHyphen(uid))}");
            if (await doMultipleEmployersExist(extractBeforeSecondHyphen(uid))) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Employer_JObID_Choose()),
              );
            }
            else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EmployerMenuPage()),
              );
            }
          } else {
            // Navigate to MenuSplashScreen as default
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuSplashScreen()),
            );
          }
          print('User logged in successfully: ${firebaseUser.uid}');
          // Perform any other tasks, such as navigating to a new page
        } else {
          // User authentication failed
          print('User authentication failed');
        }
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<String> checkUserExistence(String uid) async {
    // Check in User_Employee collection
    var employeeDoc = await FirebaseFirestore.instance.collection('User_Employee').doc(uid).get();
    if (employeeDoc.exists) {
      return 'User_Employee';
    }

    // Check in User_Employer collection
    var employerDoc = await FirebaseFirestore.instance.collection('User_Employer').doc(uid).get();
    if (employerDoc.exists) {
      return 'User_Employer';
    }

    // If not found in either collection
    return '';
  }

  _registerWithEmailAndPassword() async {
    print("******** Mail Verification ********\n");
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() {
      reg_state = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please verify email before creating account.',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    User user_sub = await FirebaseAuth.instance.currentUser!;
    int mail_verify_time = 0;

    await FirebaseAuth.instance.authStateChanges().listen((user) async {
      user_sub.sendEmailVerification();
      while (user_sub.emailVerified == false) {
        await Future.delayed(Duration(milliseconds: 600));
        await user_sub.reload();
        user_sub = await FirebaseAuth.instance.currentUser!;
        mail_verify_time = mail_verify_time + 1;
        if (mail_verify_time > 60) {
          break;
        }
      }
      if (user_sub.emailVerified) {
        setState(() {
          current_user_uid = FirebaseAuth.instance.currentUser!.uid;
          current_user_mail = FirebaseAuth.instance.currentUser!.email;
          current_user_displayName = FirebaseAuth.instance.currentUser!.displayName;
          uid = "${current_user_mail} - ${current_user_uid}";
        });
        print("************************************");
        print(current_user_uid);
        print(current_user_mail);
        print(current_user_displayName);
        print("************************************");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenuSplashScreen(),
          ),
        );
        /* setState(() {
          formatted_phone_val = "+91" + phone_no.trim();
        });
        setState(() {
          reg_state = 2;
        });
        await Future.delayed(Duration(milliseconds: 3000));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneVerificationWidget(phone_val: formatted_phone_val,
              ph_no: phone_no,password: _passwordController.text,),
          ),
        ); */
      } else {
        user_sub.delete();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create the Account.')));
      }
    });
  }

  Future<bool> userExists(String email, String password, BuildContext context) async {
    try {
      // Attempt to sign in the user
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User exists, return true
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // User not found, return false
        return false;
      } else {
        // Handle other FirebaseAuthExceptions
        // (e.g., invalid password, too many attempts)
        print("FirebaseAuthException: ${e.message}");
        // Return false or handle the exception according to your app logic
        return false;
      }
    } catch (e) {
      // Handle other exceptions
      print("Error: $e");
      // Return false or handle the exception according to your app logic
      return false;
    }
  }

  Future<void> _vibrate() async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
    }
  }

  @override
  Widget build(BuildContext context) {
    double total_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onVerticalDragUpdate: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Create your account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Container(
            height: total_height,
            child: Padding(
            padding: const EdgeInsets.only(left:16.0, right: 16, top:8),
            child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Container(
              padding: EdgeInsets.only(top: 14,bottom: 14,left: 10,right: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                  labelText: 'Email ID*',
                  hintText:
                  'For sending relevant updates',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Specify your border color here
                        width: 2.0, // Specify your border width here
                      ),
                    ),
                  ),
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                  }
                  return null;
                  },
                  ),
                  /* const SizedBox(height: 10.0),
                  TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                  labelText: 'Mobile number*',
                  hintText: 'Used for all sort of verbal communication',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Specify your border color here
                        width: 2.0, // Specify your border width here
                      ),
                    ),
                  ),
                  validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                  }
                  return null;
                  },
                  onChanged: (value) {
                  setState(() {
                  phone_no = value;
                  });
                  },
                  ), */
                  const SizedBox(height: 10.0),
                  TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                  labelText: 'Password*',
                  hintText: 'This helps your account stay protected',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Specify your border color here
                        width: 2.0, // Specify your border width here
                      ),
                    ),
                  ),
                  validator: (value) {
                  if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                  }
                  return null;
                  },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            const Row(
            children: [
            Checkbox(value: true, onChanged: null),
            Text('Send me important updates'),
            ],
            ),
            const SizedBox(height: 10.0),
            Container(
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                _vibrate();
                FocusScope.of(context).unfocus();
                // Check if fields are blank
                if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Email and password cannot be empty.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                // Check if phone number is blank
                /* else if (_phoneNumberController.text.isEmpty || !RegExp(r'^[0-9]{10}$').hasMatch(_phoneNumberController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Phone number cannot be empty or invalid.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } */
                // Validate email format
                else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter a valid email address.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                // Validate password length
                else if (_passwordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password must be at least 6 characters long.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                // Check if the user already exists
                else {
                  bool userAlreadyExists;
                  userAlreadyExists = await userExists(_emailController.text, _passwordController.text, context);
                  if (userAlreadyExists) {
                    // User exists, handle accordingly (maybe show a message or navigate to a login screen)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'User already exists. Please log in.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  else {
                    // User does not exist, proceed with registration
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please verify mail to create account.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    _registerWithEmailAndPassword();
                  }
                }
              },
              style: OutlinedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text(
            'Register',
            style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            ),
            ),
            const SizedBox(height: 20.0),
            Container(
            height: 50,
            child: ElevatedButton.icon(
            onPressed: () async {
            _vibrate();
            FocusScope.of(context).unfocus();
            handleGoogleSignIn();
            },
            icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
            label: const Text(
            'Signup with Google',
            style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF0000), // Google red
            ),
            ),
            ),
            const SizedBox(height: 20.0),
            const Text(
            '*All your activity will remain private',
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            ),
              reg_state == 2 ? Container(height:180, child: Lottie.asset('images/tick.json')) :
              reg_state == 1 ? Container(height:180, child: Lottie.asset('images/load.json')) :
              Container(height:180, child: Lottie.asset('images/form.json')),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Image.asset(
                        'images/job mini.png', // Adjust the BoxFit as needed
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],
            )
            ),
            ),
          ),
        )
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> Login_formKey = GlobalKey<FormState>();
  String Login_uname = "";
  String Login_pwd = "";
  final List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];
  late GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  void handleGoogleSignIn() async {
    await FirebaseAuth.instance.signOut();
    try {
      // Initialize GoogleSignIn
      _googleSignIn = GoogleSignIn(scopes: scopes);

      // Listen for changes in the current user
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
        setState(() {
          _currentUser = account;
        });
      });

      // Attempt silent sign-in
      await _googleSignIn.signInSilently();

      // Sign out the current user
      await _googleSignIn.signOut();

      // Handle sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;
        // Update ID's
        await firestoreService.updateEmployeeIds();
        await firestoreService.updateEmployerIds();
        if (firebaseUser != null) {
          // Update the state with user information
          setState(() {
            current_user_uid = userCredential.user!.uid;
            current_user_mail = userCredential.user!.email;
            current_user_displayName = userCredential.user!.displayName;
            uid = "${current_user_mail} - ${current_user_uid}";
          });
          print("************************************");
          print(current_user_uid);
          print(current_user_mail);
          print(current_user_displayName);
          print("***********************************&");
          Future<bool> doesEmployeeExist() async =>
              await FirebaseFirestore.instance.collection('User_Employee').doc(uid).get().then((doc) => doc.exists);
          String extractBeforeSecondHyphen(String input) {
            List<String> parts = input.split(' - ');
            if (parts.length > 2) {
              return parts.sublist(0, 2).join(' - ');
            } else {
              return input;
            }
          }
          Future<bool> doesEmployerExist() async {
            String prefix = extractBeforeSecondHyphen(uid);
            CollectionReference employersCollection = FirebaseFirestore.instance.collection('User_Employer');
            QuerySnapshot querySnapshot = await employersCollection.where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix).get();
            return querySnapshot.docs.any((doc) => doc.id.startsWith(prefix));
          }
          Future<bool> doMultipleEmployersExist(String uid) async {
            String prefix = extractBeforeSecondHyphen(uid);
            CollectionReference employersCollection = FirebaseFirestore.instance.collection('User_Employer');
            QuerySnapshot querySnapshot = await employersCollection.where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix).get();
            int count = querySnapshot.docs.where((doc) => doc.id.startsWith(prefix)).length;
            return count > 1;
          }
          if (await doesEmployeeExist()) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmployeeMenuPage()),
            );
          } else if (await doesEmployerExist()) {
            print("Is there multiple documents? - "
                "${await doMultipleEmployersExist(extractBeforeSecondHyphen(uid))}");
            if (await doMultipleEmployersExist(extractBeforeSecondHyphen(uid))) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Employer_JObID_Choose()),
              );
            }
            else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EmployerMenuPage()),
              );
            }
          } else {
            // Navigate to MenuSplashScreen as default
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuSplashScreen()),
            );
          }
          print('User logged in successfully: ${firebaseUser.uid}');
          // Perform any other tasks, such as navigating to a new page
        } else {
          // User authentication failed
          print('User authentication failed');
        }
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<String> checkUserExistence(String uid) async {
    // Check in User_Employee collection
    var employeeDoc = await FirebaseFirestore.instance.collection('User_Employee').doc(uid).get();
    if (employeeDoc.exists) {
      return 'User_Employee';
    }

    // Check in User_Employer collection
    var employerDoc = await FirebaseFirestore.instance.collection('User_Employer').doc(uid).get();
    if (employerDoc.exists) {
      return 'User_Employer';
    }

    // If not found in either collection
    return '';
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    RegExp r = RegExp(r'^[0-9]+$');
    if (r.hasMatch(email)) {
      email = email + "@jopple.com";
    }
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? firebaseUser = userCredential.user;
      // Handle successful sign-in
      // Update ID's
      await firestoreService.updateEmployeeIds();
      await firestoreService.updateEmployerIds();
      if (firebaseUser != null) {
        // Update the state with user information
        setState(() {
          current_user_uid = userCredential.user!.uid;
          current_user_mail = userCredential.user!.email;
          current_user_displayName = userCredential.user!.displayName;
          uid = "${current_user_mail} - ${current_user_uid}";
        });
        print("************************************");
        print(current_user_uid);
        print(current_user_mail);
        print(current_user_displayName);
        print("***********************************&");
        Future<bool> doesEmployeeExist() async =>
            await FirebaseFirestore.instance.collection('User_Employee').doc(uid).get().then((doc) => doc.exists);
        String extractBeforeSecondHyphen(String input) {
          List<String> parts = input.split(' - ');
          if (parts.length > 2) {
            return parts.sublist(0, 2).join(' - ');
          } else {
            return input;
          }
        }
        Future<bool> doesEmployerExist() async {
          String prefix = extractBeforeSecondHyphen(uid);
          CollectionReference employersCollection = FirebaseFirestore.instance.collection('User_Employer');
          QuerySnapshot querySnapshot = await employersCollection.where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix).get();
          return querySnapshot.docs.any((doc) => doc.id.startsWith(prefix));
        }
        Future<bool> doMultipleEmployersExist(String uid) async {
          String prefix = extractBeforeSecondHyphen(uid);
          CollectionReference employersCollection = FirebaseFirestore.instance.collection('User_Employer');
          QuerySnapshot querySnapshot = await employersCollection.where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix).get();
          int count = querySnapshot.docs.where((doc) => doc.id.startsWith(prefix)).length;
          return count > 1;
        }
        if (await doesEmployeeExist()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmployeeMenuPage()),
          );
        } else if (await doesEmployerExist()) {
          print("Is there multiple documents? - "
              "${await doMultipleEmployersExist(extractBeforeSecondHyphen(uid))}");
          if (await doMultipleEmployersExist(extractBeforeSecondHyphen(uid))) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Employer_JObID_Choose()),
            );
          }
          else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmployerMenuPage()),
            );
          }
        } else {
          // Navigate to MenuSplashScreen as default
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MenuSplashScreen()),
          );
        }
        print('User logged in successfully: ${firebaseUser.uid}');
        // Perform any other tasks, such as navigating to a new page
      } else {
        // User authentication failed
        print('User authentication failed');
      }
      // Return the uid
      return userCredential.user!.uid;
    } catch (e) {
      // Handle sign-in errors
      print('Sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Password.',style:
          TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      // Return null if sign-in fails
      return null;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }
    return null;
  }
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> _vibrate() async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
    }
  }

  @override
  Widget build(BuildContext context) {
    double total_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onVerticalDragUpdate: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset : false,
          appBar: AppBar(
            centerTitle: true,
          title: const Text(
          'Login to your account',
          style: TextStyle(fontWeight: FontWeight.bold),
            ),),
            body: Padding(
              padding: const EdgeInsets.only(top:8.0,left:0.0,right:0.0),
              child: Container(
                height: total_height,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                        key: Login_formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54, width: 3),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        Login_uname = value;
                                      });
                                    },
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      labelText: 'Username*',
                                      hintText:
                                      'Enter the registered mail or phone number',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black, // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                    ),
                                    ),
                                    validator: validateEmail,
                                  ),
                                  const SizedBox(height: 10.0),
                                  TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        Login_pwd = value;
                                      });
                                    },
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password*',
                                      hintText:
                                      'Enter the password',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black, // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                    validator: validatePassword,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return ForgotPasswordPage();
                                        }));
                                  },
                                  child: const Text('Forgot password',
                                      style: TextStyle(color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Container(
                              height: 50,
                              width : double.maxFinite,
                              child: OutlinedButton(
                                onPressed: () {
                                  _vibrate();
                                  FocusScope.of(context).unfocus();
                                  signInWithEmailAndPassword(
                                      Login_uname, Login_pwd);
                                },
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.black),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Container(
                              height: 50,
                              width : double.maxFinite,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  _vibrate();
                                  FocusScope.of(context).unfocus();
                                  handleGoogleSignIn();
                                },
                                icon: const FaIcon(FontAwesomeIcons.google,color: Colors.white,),
                                label: const Text(' Login with Google',style: TextStyle(color: Colors.white,fontSize: 18)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF0000), // Google red
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New user? Click here for',
                                      style: TextStyle(color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _vibrate();
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return RegisterPage();
                                        }));
                                  },
                                  child: Text(
                                       ' register...',
                                        style: TextStyle(color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                            const Text(
                              '*All your activity will remain private',
                              style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                            Container(height:215,child: Lottie.asset('images/login.json')),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'images/job mini.png', // Adjust the BoxFit as needed
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        )))
              ),
            )
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.sendPasswordResetEmail(email: _email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $_email'),
          ),
        );

        // Navigate to LoginPage after sending the password reset email
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
          ),
        );
      }
    }
  }
  Future<void> _vibrate() async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text('Forgot Password',style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: height * 0.92,
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.justify,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      hintText: "Please enter the registered mail"
                    ),
                    validator: (input) {
                      if (input == null || input.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onSaved: (input) => _email = input!,
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _resetPassword();
                        _vibrate();
                        FocusScope.of(context).unfocus();
                      },
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.black),
                      child: Text('Reset Password',style: TextStyle(color: Colors.white, fontSize: 18),),
                    ),
                  ),
                  SizedBox(height: 35.0),
                  Container(height: 200, width: 200, child: Lottie.asset('images/key.json')),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          'images/job mini.png', // Adjust the BoxFit as needed
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* class PhoneVerificationWidget extends StatefulWidget {
  const PhoneVerificationWidget({super.key,required this.phone_val,required this.ph_no,required this.password});
  final String phone_val;
  final String ph_no;
  final String password;
  @override
  _PhoneVerificationWidgetState createState() => _PhoneVerificationWidgetState();
}
class _PhoneVerificationWidgetState extends State<PhoneVerificationWidget> {

  TextEditingController _otpController = TextEditingController();
  bool otpV = false;
  bool otpSubmitState = false;
  bool v_state = false;
  bool vv_state = false;
  String otp = '';

  Future<void> _createAccountWithPhoneNumber(
      BuildContext context) async {
    print("******** Phone Verification ********");
    String phoneNumber;
    try {
      phoneNumber = widget.phone_val;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        //*********************************************************//
        verificationCompleted: (PhoneAuthCredential credential) {
          FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((userCredential) async {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Phone number verification completed: ${userCredential.user?.uid}")));
          });
        },
        //*********************************************************//
        verificationFailed: (FirebaseAuthException e) async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Phone number verification failed: ${e.message} - ${phoneNumber}")));
        },
        //*********************************************************//
        codeSent: (String verificationId, int? resendToken) async {
          var potp_wait_time = 0;
          while (otpSubmitState == false) {
            await Future.delayed(Duration(seconds: 1));
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId, smsCode: otp);
            FirebaseAuth.instance
                .signInWithCredential(credential)
                .then((userCredential) async {
              FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: widget.ph_no + "@jopple.com",
                password: widget.password,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuSplashScreen(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Verification completed, Account Added",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ));
            });
            potp_wait_time = potp_wait_time + 1;
            if (potp_wait_time > 60) {
              setState(() {
                otpV = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "OTP Verification Timeout")));
              break;
            }
          }
        },
        //*********************************************************//
        codeAutoRetrievalTimeout: (String verificationId) {
        },
        timeout: Duration(seconds: 60),
        //*********************************************************//
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text("Error occurred during phone number verification: $e")));
    }
  }

  Future<void> _vibrate() async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Container(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: v_state == false,
                child: _buildVerificationView(context),
              ),
              Visibility(
                visible: v_state == true,
                child: _buildOTPView(context),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Image.asset(
                        'images/job mini.png', // Adjust the BoxFit as needed
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationView(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        height: height * 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Do you wish to verify your phone number now?',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  height: 1.7,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _vibrate();
                    _createAccountWithPhoneNumber(context);
                    setState(() {
                      v_state = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _vibrate();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Change button color to green
                  ),
                  child: Text('No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPView(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 16.0,right: 16.0),
      child: Container(
        height: height * 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Phone OTP Verification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(height: 40.0),
            Container(
              child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter OTP sent to your number",
                  )
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      _vibrate();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _vibrate();
                        FocusScope.of(context).unfocus();
                        otp = _otpController.text.trim();
                        otpSubmitState = true;
                      });
                    },
                    child: Text(
                      'Submit OTP',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      _vibrate();
                      _createAccountWithPhoneNumber(context);
                      setState(() {
                        otpV = false;
                      });
                    },
                    child: Text(
                      'Send Again',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 35.0),
            otpV
                ? Column(
              children: [
                Container(
                  height: 130,
                  child: Lottie.asset('images/vfailed.json'),
                ),
                SizedBox(height: 20.0),
                Text(
                  'OTP verification expired',
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            )
                : Column(
              children: [
                Container(
                  height: 180,
                  child: Lottie.asset('images/otpw.json'),
                ),
                SizedBox(height: 20.0),
                Text(
                  'OTP verification pending',
                  style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 60.0),
            Container(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _vibrate();
                  FocusScope.of(context).unfocus();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuSplashScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.keyboard_arrow_right, color: Colors.black),
                label: const Text(
                  'Proceed without number',
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} */