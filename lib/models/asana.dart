import 'package:cloud_firestore/cloud_firestore.dart';

class Asana {
  final String id;
  final String name;
  final String sanskritName;
  final String videoUrl;
  final int durationSecs;
  final String difficulty;

  const Asana({
    required this.id,
    required this.name,
    required this.sanskritName,
    required this.videoUrl,
    required this.durationSecs,
    required this.difficulty,
  });

  factory Asana.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Asana(
      id: doc.id,
      name: d['name'] as String,
      sanskritName: d['sanskritName'] as String,
      videoUrl: d['videoUrl'] as String,
      durationSecs: (d['durationSecs'] as num).toInt(),
      difficulty: d['difficulty'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'sanskritName': sanskritName,
    'videoUrl': videoUrl,
    'durationSecs': durationSecs,
    'difficulty': difficulty,
  };
}
