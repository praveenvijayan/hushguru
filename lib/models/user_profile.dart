import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String practiceLevel;
  final String sessionDuration;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.practiceLevel,
    required this.sessionDuration,
  });

  factory UserProfile.defaults({
    required String uid,
    required String displayName,
    required String email,
  }) => UserProfile(
    uid: uid,
    displayName: displayName,
    email: email,
    practiceLevel: 'intermediate',
    sessionDuration: '20 minutes',
  );

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return UserProfile(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? '',
      email: d['email'] as String? ?? '',
      practiceLevel: d['practiceLevel'] as String? ?? 'intermediate',
      sessionDuration: d['sessionDuration'] as String? ?? '20 minutes',
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'email': email,
    'practiceLevel': practiceLevel,
    'sessionDuration': sessionDuration,
  };
}
