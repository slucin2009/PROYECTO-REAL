import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5kmaMqHeY4nX5bMAH8Z4ZqAeUwpSINlw',
    appId: '1:539397156783:android:23a67ed921d96b1f6f495a',
    messagingSenderId: '539397156783',
    projectId: 'campusfix-66e5d',
    storageBucket: 'campusfix-66e5d.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TU_API_KEY_WEB',
    appId: 'TU_APP_ID_WEB',
    messagingSenderId: '539397156783',
    projectId: 'campusfix-66e5d',
    storageBucket: 'campusfix-66e5d.firebasestorage.app',
  );
}