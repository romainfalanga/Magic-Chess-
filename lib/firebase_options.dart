// ============================================================
// FIREBASE OPTIONS - magichess-af025
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDX_qUYBfXGNOwn0BLwN8Crj0u_f6O2cxA',
    authDomain: 'magichess-af025.firebaseapp.com',
    projectId: 'magichess-af025',
    storageBucket: 'magichess-af025.firebasestorage.app',
    messagingSenderId: '809435709885',
    appId: '1:809435709885:web:ee7bf1813b2587bc6612d4',
    measurementId: 'G-J1WYPDLTKT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDX_qUYBfXGNOwn0BLwN8Crj0u_f6O2cxA',
    authDomain: 'magichess-af025.firebaseapp.com',
    projectId: 'magichess-af025',
    storageBucket: 'magichess-af025.firebasestorage.app',
    messagingSenderId: '809435709885',
    appId: '1:809435709885:web:ee7bf1813b2587bc6612d4',
  );
}
