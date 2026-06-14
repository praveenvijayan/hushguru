import 'package:cloud_firestore/cloud_firestore.dart';

class PracticeSession {
  final String id;
  final DateTime timestamp;
  final String asanaName;
  final int durationSecs;
  final String guideTranscript;

  const PracticeSession({
    required this.id,
    required this.timestamp,
    required this.asanaName,
    required this.durationSecs,
    required this.guideTranscript,
  });

  factory PracticeSession.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PracticeSession(
      id: doc.id,
      timestamp: (d['timestamp'] as Timestamp).toDate(),
      asanaName: d['asanaName'] as String? ?? '',
      durationSecs: (d['durationSecs'] as num?)?.toInt() ?? 0,
      guideTranscript: d['guideTranscript'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'timestamp': FieldValue.serverTimestamp(),
    'asanaName': asanaName,
    'durationSecs': durationSecs,
    'guideTranscript': guideTranscript,
  };
}
