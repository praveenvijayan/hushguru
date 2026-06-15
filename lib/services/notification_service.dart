import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  // Intentionally empty — the app router handles navigation when opened.
}

class NotificationService {
  NotificationService._();

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  static Future<void> init(String uid) async {
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
          '[NotificationService] APNS token unavailable after retries '
          '(simulator or APNs error) — skipping FCM token.',
        );
        return;
      }
    }

    final token = await messaging.getToken();
    if (token != null) await _storeToken(uid, token);

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
