import 'package:flutter/material.dart';
import '../models/practice_session.dart';
import '../services/session_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ProgressJournal extends StatelessWidget {
  final String uid;

  const ProgressJournal({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Progress journal', style: HgText.eyebrow()),
        const SizedBox(height: 16),
        StreamBuilder<List<PracticeSession>>(
          stream: SessionService.recentStream(uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(
                    color: HgColors.coral,
                    strokeWidth: 1.5,
                  ),
                ),
              );
            }
            final sessions = snap.data ?? [];
            if (sessions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No sessions yet — complete a practice to see your history.',
                  style: HgText.body(color: HgColors.ink60),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: HgColors.ink12),
              itemBuilder: (_, i) => _SessionRow(session: sessions[i]),
            );
          },
        ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  final PracticeSession session;

  const _SessionRow({required this.session});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatDuration(int secs) {
    if (secs < 60) return '${secs}s';
    final m = secs ~/ 60;
    final s = secs % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.asanaName,
                  style: HgText.body(color: HgColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(session.timestamp),
                  style: HgText.caption(color: HgColors.ink60),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(session.durationSecs),
            style: HgText.caption(color: HgColors.ink60),
          ),
        ],
      ),
    );
  }
}
