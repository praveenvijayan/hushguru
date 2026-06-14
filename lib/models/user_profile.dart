import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String practiceLevel;
  final String sessionDuration;
  final bool remindersEnabled;
  final String practiceTime;
  final int timezoneOffset;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.practiceLevel,
    required this.sessionDuration,
    this.remindersEnabled = true,
    this.practiceTime = '07:00',
    this.timezoneOffset = 0,
  });

  factory UserProfile.defaults({
    required String uid,
    required String displayName,
    required String email,
    int timezoneOffset = 0,
  }) => UserProfile(
    uid: uid,
    displayName: displayName,
    email: email,
    practiceLevel: 'intermediate',
    sessionDuration: '20 minutes',
    remindersEnabled: true,
    practiceTime: '07:00',
    timezoneOffset: timezoneOffset,
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
      remindersEnabled: d['remindersEnabled'] as bool? ?? true,
      practiceTime: d['practiceTime'] as String? ?? '07:00',
      timezoneOffset: d['timezoneOffset'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'email': email,
    'practiceLevel': practiceLevel,
    'sessionDuration': sessionDuration,
    'remindersEnabled': remindersEnabled,
    'practiceTime': practiceTime,
    'timezoneOffset': timezoneOffset,
  };
}
