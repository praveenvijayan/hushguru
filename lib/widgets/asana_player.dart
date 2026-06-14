import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/asana.dart';
import '../services/asana_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AsanaPlayer extends StatefulWidget {
  final void Function(String asanaName, int durationSecs)? onSessionComplete;

  const AsanaPlayer({super.key, this.onSessionComplete});

  @override
  State<AsanaPlayer> createState() => _AsanaPlayerState();
}

class _AsanaPlayerState extends State<AsanaPlayer> {
  Asana? _selected;

  void _handleBack() {
    final asana = _selected!;
    setState(() => _selected = null);
    widget.onSessionComplete?.call(asana.name, asana.durationSecs);
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _AsanaVideoPlayer(asana: _selected!, onBack: _handleBack);
    }
    return _AsanaList(onSelect: (a) => setState(() => _selected = a));
  }
}

// ─── Browsable list ──────────────────────────────────────────────────────────

class _AsanaList extends StatelessWidget {
  final void Function(Asana) onSelect;

  const _AsanaList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Asana library', style: HgText.eyebrow()),
        const SizedBox(height: 16),
        StreamBuilder<List<Asana>>(
          stream: AsanaService.stream(),
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
            final asanas = snap.data ?? [];
            if (asanas.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No poses found.',
                  style: HgText.body(color: HgColors.ink60),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: asanas.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: HgColors.ink12),
              itemBuilder: (_, i) =>
                  _AsanaRow(asana: asanas[i], onTap: () => onSelect(asanas[i])),
            );
          },
        ),
      ],
    );
  }
}

class _AsanaRow extends StatelessWidget {
  final Asana asana;
  final VoidCallback onTap;

  const _AsanaRow({required this.asana, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asana.name, style: HgText.body(color: HgColors.navy)),
                  const SizedBox(height: 2),
                  Text(
                    asana.sanskritName,
                    style: HgText.caption(color: HgColors.ink60),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _DifficultyBadge(difficulty: asana.difficulty),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: HgColors.ink40, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  static Color _color(String d) => switch (d) {
    'advanced' => HgColors.coral,
    'intermediate' => HgColors.navy,
    _ => HgColors.ink40,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color(difficulty).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(difficulty, style: HgText.caption(color: _color(difficulty))),
    );
  }
}

// ─── Video player ────────────────────────────────────────────────────────────

class _AsanaVideoPlayer extends StatefulWidget {
  final Asana asana;
  final VoidCallback onBack;

  const _AsanaVideoPlayer({required this.asana, required this.onBack});

  @override
  State<_AsanaVideoPlayer> createState() => _AsanaVideoPlayerState();
}

class _AsanaVideoPlayerState extends State<_AsanaVideoPlayer> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.asana.videoUrl))
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back + title row
        Row(
          children: [
            GestureDetector(
              onTap: widget.onBack,
              child: Icon(
                Icons.arrow_back_ios_new,
                color: HgColors.ink60,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.asana.name, style: HgText.h2()),
                  Text(
                    '${widget.asana.sanskritName}  ·  Hold ${widget.asana.durationSecs} s',
                    style: HgText.bodySmall(color: HgColors.ink60),
                  ),
                ],
              ),
            ),
            _DifficultyBadge(difficulty: widget.asana.difficulty),
          ],
        ),
        const SizedBox(height: 16),

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

        // Progress bar
        _WarmProgressBar(
          value: _initialized
              ? (_ctrl.value.position.inSeconds /
                    widget.asana.durationSecs.toDouble())
              : 0,
        ),

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
            _ControlBtn(icon: Icons.skip_next_rounded, onTap: () {}),
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
