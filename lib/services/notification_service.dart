import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  // Intentionally empty — the app router handles navigation when opened.
}

class NotificationService {
  NotificationService._();

  static bool _initialized = false;
  static bool _fcmAvailable = false;

  static bool get fcmAvailable => _fcmAvailable;

  @visibleForTesting
  static void resetForTest() {
    _initialized = false;
    _fcmAvailable = false;
  }

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  // Idempotent: subsequent calls return immediately without touching Firebase.
  static Future<void> init(String uid) async {
    if (_initialized) return;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // iOS/macOS: FCM requires the APNS token to be registered first.
    // Retry briefly to cover the window between app launch and APNs registration.
    // Simulators never receive APNS tokens — skip FCM gracefully if unavailable.
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      String? apnsToken;
      for (var i = 0; i < 3 && apnsToken == null; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      if (apnsToken == null) {
        debugPrint(
          '[NotificationService] warn: APNS token unavailable after retries '
          '(simulator or APNs error) — push notifications disabled.',
        );
        return;
      }
    }

    final token = await messaging.getToken();
    if (token != null) {
      _fcmAvailable = true;
      await _storeToken(uid, token);
    }

    messaging.onTokenRefresh.listen(
      (token) => _storeToken(uid, token),
      onError: (e) =>
          debugPrint('[NotificationService] token refresh error: $e'),
    );
  }

  static Future<void> _storeToken(String uid, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': token,
    });
  }
}
