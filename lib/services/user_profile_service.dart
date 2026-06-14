import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Retries [op] up to [maxAttempts] times when Firestore returns `unavailable`.
/// Returns true on success; false if all attempts fail. Non-unavailable
/// FirebaseExceptions are rethrown immediately.
@visibleForTesting
Future<bool> withFirestoreRetry(
  Future<void> Function() op, {
  int maxAttempts = 2,
  Duration backoff = const Duration(milliseconds: 500),
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      await op();
      return true;
    } on FirebaseException catch (e) {
      if (e.code != 'unavailable') rethrow;
      debugPrint(
        '[UserProfileService] Firestore unavailable'
        ' (attempt ${attempt + 1}/$maxAttempts): ${e.message}',
      );
      if (attempt < maxAttempts - 1) await Future.delayed(backoff);
    }
  }
  return false;
}

class UserProfileService {
  static CollectionReference<UserProfile> get _col => FirebaseFirestore.instance
      .collection('users')
      .withConverter<UserProfile>(
        fromFirestore: (snap, _) => UserProfile.fromFirestore(snap),
        toFirestore: (profile, _) => profile.toMap(),
      );

  /// Ensures a profile document exists for [user].
  /// Returns true on success; false if Firestore is unreachable after retries.
  static Future<bool> ensureProfile(User user) => withFirestoreRetry(() async {
    final ref = _col.doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final name = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!
          : user.email?.split('@').first ?? 'Friend';
      await ref.set(
        UserProfile.defaults(
          uid: user.uid,
          displayName: name,
          email: user.email ?? '',
        ),
      );
    }
  });

  static Future<void> createProfile({
    required String uid,
    required String displayName,
    required String email,
    required String practiceLevel,
    required String sessionDuration,
  }) => _col
      .doc(uid)
      .set(
        UserProfile(
          uid: uid,
          displayName: displayName,
          email: email,
          practiceLevel: practiceLevel,
          sessionDuration: sessionDuration,
        ),
      );

  static Stream<UserProfile?> stream(String uid) =>
      _col.doc(uid).snapshots().map((s) => s.data());

  static Future<void> updateField(String uid, String field, String value) =>
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        field: value,
      });
}
