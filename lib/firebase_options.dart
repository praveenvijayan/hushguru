import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsdtxLX_gDzPEMrYPIUONAZ5x3ZQIkusY',
    appId: '1:57449042012:ios:b33358667148cd4dd35699',
    messagingSenderId: '57449042012',
    projectId: 'hushguru-775f5',
    storageBucket: 'hushguru-775f5.firebasestorage.app',
    iosBundleId: 'com.hushguru.dev',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBsdtxLX_gDzPEMrYPIUONAZ5x3ZQIkusY',
    appId: '1:57449042012:ios:b33358667148cd4dd35699',
    messagingSenderId: '57449042012',
    projectId: 'hushguru-775f5',
    storageBucket: 'hushguru-775f5.firebasestorage.app',
    iosBundleId: 'com.hushguru.dev',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9VLnSMQssuiH7RQbkMjWxgrq9e8rTxuY',
    appId: '1:57449042012:android:8cd971463e214f72d35699',
    messagingSenderId: '57449042012',
    projectId: 'hushguru-775f5',
    storageBucket: 'hushguru-775f5.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: '57449042012',
    projectId: 'hushguru-775f5',
    storageBucket: 'hushguru-775f5.firebasestorage.app',
  );
}
