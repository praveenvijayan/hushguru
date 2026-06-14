import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static final _col = FirebaseFirestore.instance
      .collection('users')
      .withConverter<UserProfile>(
        fromFirestore: (snap, _) => UserProfile.fromFirestore(snap),
        toFirestore: (profile, _) => profile.toMap(),
      );

  // Creates a profile document on first sign-in; no-op if it already exists.
  static Future<void> ensureProfile(User user) async {
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
  }

  static Stream<UserProfile?> stream(String uid) =>
      _col.doc(uid).snapshots().map((s) => s.data());

  static Future<void> updateField(String uid, String field, String value) =>
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        field: value,
      });
}
