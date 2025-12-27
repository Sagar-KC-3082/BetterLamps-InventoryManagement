import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// TODO: Replace the placeholder values below with your actual Firebase config.
/// You can get these values from the Firebase Console:
/// 1. Go to https://console.firebase.google.com/
/// 2. Select your project (or create a new one)
/// 3. Click the gear icon > Project settings
/// 4. Scroll down to "Your apps" section
/// 5. Click "Add app" and select Web (</>)
/// 6. Register your app and copy the config values
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
    apiKey: 'AIzaSyDyE0GxoS56dVmL-Uu__CE0KXAfflhiNjg',
    appId: '1:767753779456:web:127e273b9208570b3c9be5',
    messagingSenderId: '767753779456',
    projectId: 'better-lamp-inventory',
    authDomain: 'better-lamp-inventory.firebaseapp.com',
    storageBucket: 'better-lamp-inventory.firebasestorage.app',
  );

  // TODO: Replace these placeholder values with your Firebase Android config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  // TODO: Replace these placeholder values with your Firebase iOS config
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.betterLampsInventory',
  );

  // TODO: Replace these placeholder values with your Firebase macOS config
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.betterLampsInventory',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDyE0GxoS56dVmL-Uu__CE0KXAfflhiNjg',
    appId: '1:767753779456:web:127e273b9208570b3c9be5',
    messagingSenderId: '767753779456',
    projectId: 'better-lamp-inventory',
    authDomain: 'better-lamp-inventory.firebaseapp.com',
    storageBucket: 'better-lamp-inventory.firebasestorage.app',
  );
}
