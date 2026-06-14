import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/practice_session.dart';

class SessionService {
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sessions');

  static Future<void> addSession(String uid, PracticeSession session) =>
      _col(uid).add(session.toMap());

  static Stream<List<PracticeSession>> recentStream(
    String uid, {
    int limit = 7,
  }) => _col(uid)
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map(PracticeSession.fromFirestore).toList());
}
