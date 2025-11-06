// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs

// GENERATED-LIKE: Manual FirebaseOptions based on google-services.json and GoogleService-Info.plist
// This avoids relying on iOS plist auto-discovery and ensures explicit init.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ? ios : android;

  // Android options from android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNa9pHyRHO8G6JGzEYUow02mkd0ZPecH8',
    appId: '1:85712037587:android:52ab72b3e70c12d61a5626',
    messagingSenderId: '85712037587',
    projectId: 'smart-do-76854',
    storageBucket: 'smart-do-76854.firebasestorage.app',
  );

  // iOS options from ios/Runner/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjDcKR99I2Aa3K-HV3IkJRsPj_wpGxowM',
    appId: '1:85712037587:ios:55f7822f3c312b931a5626',
    messagingSenderId: '85712037587',
    projectId: 'smart-do-76854',
    storageBucket: 'smart-do-76854.firebasestorage.app',
    iosBundleId: 'com.birkinapps.smartdolap',
  );
}
