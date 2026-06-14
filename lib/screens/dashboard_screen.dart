import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/ambient_background.dart';
import '../widgets/asana_player.dart';
import '../widgets/glass_card.dart';
import '../widgets/particle_wave.dart';
import '../widgets/settings_letter.dart';
import '../widgets/wordmark.dart';

enum _DashboardOverlay { none, settings, asana }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashboardOverlay _overlay = _DashboardOverlay.none;
  bool _menuOpen = false;
  bool _micDenied = false;

  @override
  void initState() {
    super.initState();
    _checkMicPermission();
  }

  Future<void> _checkMicPermission() async {
    final granted = await PermissionService.requestMicrophone();
    if (!granted && mounted) {
      setState(() => _micDenied = true);
    }
  }

  static const _statusLines = [
    'I am listening…',
    'Breathe in slowly.',
    'Hold that thought.',
    'Let your body soften.',
    'We begin in stillness.',
  ];
  int _statusIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        mode: ParticleMode.wave,
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main layer ──────────────────────────────────────────────
              Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const HgWordmark(size: 16, color: HgColors.cream),
                        GestureDetector(
                          onTap: () => setState(() => _menuOpen = !_menuOpen),
                          child: Icon(
                            Icons.more_horiz,
                            color: HgColors.cream.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Status text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        _statusLines[_statusIdx],
                        key: ValueKey(_statusIdx),
                        style: HgText.status(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Microphone denied nudge
                  if (_micDenied)
                    _MicNudge(
                      onTap: () async {
                        await openAppSettings();
                        if (mounted) {
                          final granted =
                              await PermissionService.requestMicrophone();
                          if (granted && mounted) {
                            setState(() => _micDenied = false);
                          }
                        }
                      },
                    ),

                  // Bottom composer bar
                  _TypeComposer(
                    onSend: () => setState(
                      () => _statusIdx = (_statusIdx + 1) % _statusLines.length,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),

              // ── Settings overlay ────────────────────────────────────────
              if (_overlay == _DashboardOverlay.settings)
                _OverlaySheet(
                  onClose: () =>
                      setState(() => _overlay = _DashboardOverlay.none),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Your practice', style: HgText.eyebrow()),
                      const SizedBox(height: 16),
                      const SettingsLetter(),
                    ],
                  ),
                ),

              // ── Asana player overlay ────────────────────────────────────
              if (_overlay == _DashboardOverlay.asana)
                _OverlaySheet(
                  onClose: () =>
                      setState(() => _overlay = _DashboardOverlay.none),
                  child: const AsanaPlayer(),
                ),

              // ── Menu sheet ──────────────────────────────────────────────
              if (_menuOpen)
                _DashboardMenu(
                  onClose: () => setState(() => _menuOpen = false),
                  onSettings: () => setState(() {
                    _menuOpen = false;
                    _overlay = _DashboardOverlay.settings;
                  }),
                  onAsana: () => setState(() {
                    _menuOpen = false;
                    _overlay = _DashboardOverlay.asana;
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Type composer ───────────────────────────────────────────────────────────

class _TypeComposer extends StatefulWidget {
  final VoidCallback onSend;

  const _TypeComposer({required this.onSend});

  @override
  State<_TypeComposer> createState() => _TypeComposerState();
}

class _TypeComposerState extends State<_TypeComposer> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 52,
          color: Colors.white.withValues(alpha: 0.15),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: HgText.body(color: HgColors.cream),
                  cursorColor: HgColors.coral,
                  decoration: InputDecoration(
                    hintText: 'Ask your guide…',
                    hintStyle: HgText.body(
                      color: HgColors.cream.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onSend();
                  _ctrl.clear();
                },
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: HgColors.coral,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overlay sheet ───────────────────────────────────────────────────────────

class _OverlaySheet extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const _OverlaySheet({required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
        radius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: HgColors.ink40, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard menu ──────────────────────────────────────────────────────────

class _DashboardMenu extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSettings;
  final VoidCallback onAsana;

  const _DashboardMenu({
    required this.onClose,
    required this.onSettings,
    required this.onAsana,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Today\'s practice', onAsana),
      ('Progress journal', null),
      ('Breathing library', null),
      ('Your settings', onSettings),
      ('About HushGuru', null),
    ];

    return Positioned(
      right: 16,
      top: 56,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        radius: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...items.map(
              (item) => _MenuItem(label: item.$1, onTap: item.$2 ?? () {}),
            ),
            const Divider(height: 1, color: Color(0x1A203C6B)),
            _MenuItem(
              label: 'Return to listening',
              onTap: onClose,
              color: HgColors.coral,
            ),
            const Divider(height: 1, color: Color(0x1A203C6B)),
            _MenuItem(
              label: 'Sign out',
              onTap: () => FirebaseAuth.instance.signOut(),
              color: HgColors.ink40,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mic permission nudge ────────────────────────────────────────────────────

class _MicNudge extends StatelessWidget {
  final VoidCallback onTap;

  const _MicNudge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: HgColors.coral.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: HgColors.coral.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Text(
          'Microphone access is needed to hear you — tap to open settings.',
          style: HgText.body(color: HgColors.cream),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─── Menu item ───────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Text(label, style: HgText.body(color: color ?? HgColors.navy)),
      ),
    );
  }
}
