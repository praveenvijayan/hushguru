import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AsanaPlayer extends StatefulWidget {
  const AsanaPlayer({super.key});

  @override
  State<AsanaPlayer> createState() => _AsanaPlayerState();
}

class _AsanaPlayerState extends State<AsanaPlayer> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;

  // Public domain yoga video from Pexels
  static const _videoUrl =
      'https://videos.pexels.com/video-files/3209828/3209828-uhd_2560_1440_25fps.mp4';

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _ctrl.setLooping(true);
          _ctrl.play();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video pane
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _initialized
                ? VideoPlayer(_ctrl)
                : Container(
                    color: HgColors.ink12,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: HgColors.coral,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // Asana label
        Text('Vrikshasana', style: HgText.h2()),
        const SizedBox(height: 4),
        Text('Tree Pose  ·  Hold 60 s', style: HgText.bodySmall(color: HgColors.ink60)),

        const SizedBox(height: 20),

        // Progress bar
        _WarmProgressBar(value: _initialized ? _ctrl.value.position.inSeconds / 60.0 : 0),

        const SizedBox(height: 20),

        // Controls row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlBtn(
              icon: Icons.skip_previous_rounded,
              onTap: () => _ctrl.seekTo(Duration.zero),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () => setState(
                () => _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play(),
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: HgColors.coral,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _initialized && _ctrl.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: HgColors.cream,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 24),
            _ControlBtn(
              icon: Icons.skip_next_rounded,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _WarmProgressBar extends StatelessWidget {
  final double value;

  const _WarmProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: HgColors.ink12,
        valueColor: const AlwaysStoppedAnimation<Color>(HgColors.coral),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: HgColors.ink60, size: 28),
    );
  }
}
