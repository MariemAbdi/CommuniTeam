// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDs9jDyA9QxJ1mz0bKR20dWhpmsU6Qv3Tw',
    appId: '1:5435122554:web:2c329b4140a9ed51c16cc3',
    messagingSenderId: '5435122554',
    projectId: 'communiteam-fd07b',
    authDomain: 'communiteam-fd07b.firebaseapp.com',
    storageBucket: 'communiteam-fd07b.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkiHgt4fmfP7JgI1Z2nuvvXK1I2nzvnBE',
    appId: '1:5435122554:android:ae49f9dda7addd3fc16cc3',
    messagingSenderId: '5435122554',
    projectId: 'communiteam-fd07b',
    storageBucket: 'communiteam-fd07b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzD6b_VOwa63ihKXjT9PWqhA7cYHePJw4',
    appId: '1:5435122554:ios:3b29eb4b9099023ec16cc3',
    messagingSenderId: '5435122554',
    projectId: 'communiteam-fd07b',
    storageBucket: 'communiteam-fd07b.appspot.com',
    iosClientId: '5435122554-b1e92govkki5302m8ffekmo7j23qit70.apps.googleusercontent.com',
    iosBundleId: 'com.example.communiteam',
  );
}
