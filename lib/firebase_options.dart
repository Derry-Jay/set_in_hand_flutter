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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAlepvWrz0tmfBtBzq_PpkMJNSK75OD3NE',
    appId: '1:775103723193:web:c9819afa0d05a0b16fcd68',
    messagingSenderId: '775103723193',
    projectId: 'set-in-hand',
    authDomain: 'set-in-hand.firebaseapp.com',
    storageBucket: 'set-in-hand.appspot.com',
    measurementId: 'G-VEHCJMF29P',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQ8zcFJUclbhO-pfJdEqSXhAorBq3GP1g',
    appId: '1:775103723193:ios:1ac5be0bb3505c316fcd68',
    messagingSenderId: '775103723193',
    projectId: 'set-in-hand',
    storageBucket: 'set-in-hand.appspot.com',
    iosClientId: '775103723193-vj0kg9m70tsd8bs6vnmo3v5op5ucpamm.apps.googleusercontent.com',
    iosBundleId: 'com.sih.myapp',
  );
}