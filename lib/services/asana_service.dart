import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asana.dart';

class AsanaService {
  static const _collection = 'asanas';

  static final _db = FirebaseFirestore.instance;

  static Stream<List<Asana>> stream() => _db
      .collection(_collection)
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs.map(Asana.fromFirestore).toList());

  /// Seeds the collection with starter poses if it is empty.
  static Future<void> seedIfEmpty() async {
    final snap = await _db.collection(_collection).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    const videoUrl =
        'https://videos.pexels.com/video-files/3209828/3209828-uhd_2560_1440_25fps.mp4';

    final poses = [
      Asana(
        id: 'vrikshasana',
        name: 'Tree Pose',
        sanskritName: 'Vrikshasana',
        videoUrl: videoUrl,
        durationSecs: 60,
        difficulty: 'beginner',
      ),
      Asana(
        id: 'adho-mukha-svanasana',
        name: 'Downward Dog',
        sanskritName: 'Adho Mukha Svanasana',
        videoUrl: videoUrl,
        durationSecs: 45,
        difficulty: 'beginner',
      ),
      Asana(
        id: 'virabhadrasana-i',
        name: 'Warrior I',
        sanskritName: 'Virabhadrasana I',
        videoUrl: videoUrl,
        durationSecs: 60,
        difficulty: 'intermediate',
      ),
      Asana(
        id: 'trikonasana',
        name: 'Triangle Pose',
        sanskritName: 'Trikonasana',
        videoUrl: videoUrl,
        durationSecs: 45,
        difficulty: 'intermediate',
      ),
      Asana(
        id: 'sirsasana',
        name: 'Headstand',
        sanskritName: 'Sirsasana',
        videoUrl: videoUrl,
        durationSecs: 30,
        difficulty: 'advanced',
      ),
    ];

    final batch = _db.batch();
    for (final pose in poses) {
      batch.set(_db.collection(_collection).doc(pose.id), pose.toMap());
    }
    await batch.commit();
  }
}
