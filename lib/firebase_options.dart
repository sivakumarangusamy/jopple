// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB9Mj2vuQsk_Zc1cVJu1ErmOMTdLNqlrhY',
    appId: '1:186179923089:web:35259b387d0d3336e6a330',
    messagingSenderId: '186179923089',
    projectId: 'jopple',
    authDomain: 'jopple.firebaseapp.com',
    storageBucket: 'jopple.appspot.com',
    measurementId: 'G-Z68YRV6ZDM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3vPC8amIza1B85WAps5bng6mTVA4mvu8',
    appId: '1:186179923089:android:7be14af082e7e11fe6a330',
    messagingSenderId: '186179923089',
    projectId: 'jopple',
    storageBucket: 'jopple.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJrUFD5ONuasl0W3jJOdL_bffVJSjRzeU',
    appId: '1:186179923089:ios:d597570c93677ad6e6a330',
    messagingSenderId: '186179923089',
    projectId: 'jopple',
    storageBucket: 'jopple.appspot.com',
    androidClientId: '186179923089-22ume63l3hd5f3gr6qafp8s1b6sekl9d.apps.googleusercontent.com',
    iosClientId: '186179923089-vc9ndsuifl32lkh40ugljasp3p1f20t2.apps.googleusercontent.com',
    iosBundleId: 'com.example.jopple',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCJrUFD5ONuasl0W3jJOdL_bffVJSjRzeU',
    appId: '1:186179923089:ios:d597570c93677ad6e6a330',
    messagingSenderId: '186179923089',
    projectId: 'jopple',
    storageBucket: 'jopple.appspot.com',
    androidClientId: '186179923089-22ume63l3hd5f3gr6qafp8s1b6sekl9d.apps.googleusercontent.com',
    iosClientId: '186179923089-vc9ndsuifl32lkh40ugljasp3p1f20t2.apps.googleusercontent.com',
    iosBundleId: 'com.example.jopple',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB9Mj2vuQsk_Zc1cVJu1ErmOMTdLNqlrhY',
    appId: '1:186179923089:web:d495ce3bd7bc8388e6a330',
    messagingSenderId: '186179923089',
    projectId: 'jopple',
    authDomain: 'jopple.firebaseapp.com',
    storageBucket: 'jopple.appspot.com',
    measurementId: 'G-S0QCX73WSN',
  );
}