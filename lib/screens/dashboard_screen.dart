import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_profile.dart';
import '../models/practice_session.dart';
import '../services/claude_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/session_service.dart';
import '../services/tts_service.dart';
import '../services/user_profile_service.dart';
import '../services/voice_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/ambient_background.dart';
import '../widgets/asana_player.dart';
import '../widgets/glass_card.dart';
import '../widgets/particle_wave.dart';
import '../widgets/progress_journal.dart';
import '../widgets/recording_pulse.dart';
import '../widgets/settings_letter.dart';
import '../widgets/wordmark.dart';

enum _DashboardOverlay { none, settings, asana, journal }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashboardOverlay _overlay = _DashboardOverlay.none;
  bool _menuOpen = false;
  bool _micDenied = false;
  bool _isRecording = false;
  bool _isResponding = false;
  String? _transcription;
  String _responseBuffer = '';
  String _ttsBuffer = '';
  StreamSubscription<String>? _guideSubscription;
  Stream<UserProfile?>? _profileStream;

  final _voiceService = VoiceService();
  final _claudeService = ClaudeService();
  final _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _checkMicPermission();
    _ttsService.init();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _profileStream = UserProfileService.stream(user.uid);
      _syncProfile(user);
      _initNotifications(user.uid);
    }
  }

  Future<void> _syncProfile(User user) async {
    final synced = await UserProfileService.ensureProfile(user);
    if (!synced && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect — please check your connection.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _initNotifications(String uid) async {
    await NotificationService.init(uid);
    if (!NotificationService.fcmAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Push notifications are unavailable on this device.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _guideSubscription?.cancel();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _editField(
    BuildContext context,
    String label,
    String current,
    String firestoreKey,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ctrl = TextEditingController(text: current);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label, style: HgText.body(color: HgColors.navy)),
        backgroundColor: HgColors.shell,
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: HgText.body(color: HgColors.navy),
          cursorColor: HgColors.coral,
          decoration: const InputDecoration(border: UnderlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: HgText.caption(color: HgColors.ink60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text('Save', style: HgText.caption(color: HgColors.coral)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (saved != null && saved.isNotEmpty) {
      await UserProfileService.updateField(uid, firestoreKey, saved);
    }
  }

  Future<void> _editLevel(BuildContext context, String current) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    const levels = ['beginner', 'intermediate', 'advanced'];
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Practice level', style: HgText.body(color: HgColors.navy)),
        backgroundColor: HgColors.shell,
        children: levels
            .map(
              (l) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, l),
                child: Text(
                  l,
                  style: HgText.body(
                    color: l == current ? HgColors.coral : HgColors.navy,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null && selected != current) {
      await UserProfileService.updateField(uid, 'practiceLevel', selected);
    }
  }

  Future<void> _toggleReminders(bool current) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await UserProfileService.updateField(uid, 'remindersEnabled', !current);
  }

  Future<void> _editPracticeTime(BuildContext context, String current) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final parts = current.split(':');
    final hour = int.tryParse(parts.firstOrNull ?? '7') ?? 7;
    final minute = int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: HgColors.coral,
            surface: HgColors.shell,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    await UserProfileService.updateField(uid, 'practiceTime', timeStr);
    await UserProfileService.updateField(uid, 'timezoneOffset', offsetMinutes);
  }

  Future<void> _recordSession(String asanaName, int durationSecs) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final session = PracticeSession(
      id: '',
      timestamp: DateTime.now(),
      asanaName: asanaName,
      durationSecs: durationSecs,
      guideTranscript: _responseBuffer,
    );
    await SessionService.addSession(uid, session);
  }

  Future<void> _checkMicPermission() async {
    final granted = await PermissionService.requestMicrophone();
    if (!granted && mounted) {
      setState(() => _micDenied = true);
    }
  }

  void _startRecording() {
    if (_micDenied) return;
    setState(() {
      _isRecording = true;
      _transcription = null;
    });
    _voiceService.startListening(
      onResult: (text) {
        if (mounted) setState(() => _transcription = text);
      },
    );
  }

  Future<void> _stopRecording() async {
    await _voiceService.stopListening();
    if (!mounted) return;
    setState(() => _isRecording = false);
    final text = _transcription;
    if (text != null && text.trim().isNotEmpty) _sendToGuide(text);
  }

  void _sendToGuide(String text) {
    if (text.trim().isEmpty) return;
    _guideSubscription?.cancel();
    setState(() {
      _isResponding = true;
      _responseBuffer = '';
      _transcription = null;
    });
    _ttsService.stop();
    _ttsBuffer = '';

    _guideSubscription = _claudeService
        .stream(userMessage: text)
        .listen(
          (chunk) {
            if (!mounted) return;
            setState(() => _responseBuffer += chunk);
            _ttsBuffer += chunk;
            final match = RegExp(r'^(.*[.!?])\s*').firstMatch(_ttsBuffer);
            if (match != null) {
              final sentence = match.group(1)!.trim();
              if (sentence.isNotEmpty) _ttsService.speak(sentence);
              _ttsBuffer = _ttsBuffer.substring(match.end);
            }
          },
          onDone: () {
            if (!mounted) return;
            setState(() => _isResponding = false);
            final remaining = _ttsBuffer.trim();
            if (remaining.isNotEmpty) {
              _ttsService.speak(remaining);
              _ttsBuffer = '';
            }
          },
          onError: (_) {
            if (mounted) setState(() => _isResponding = false);
          },
          cancelOnError: true,
        );
  }

  static const _statusLines = [
    'I am listening…',
    'Breathe in slowly.',
    'Hold that thought.',
    'Let your body soften.',
    'We begin in stillness.',
  ];
  final int _statusIdx = 0;

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
                      child: _isRecording
                          ? Row(
                              key: const ValueKey('recording'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const RecordingPulse(),
                                const SizedBox(width: 10),
                                Text('Listening…', style: HgText.status()),
                              ],
                            )
                          : Text(
                              _isResponding
                                  ? (_responseBuffer.isEmpty
                                        ? '…'
                                        : _responseBuffer)
                                  : (_transcription ??
                                        _statusLines[_statusIdx]),
                              key: ValueKey(
                                _isResponding
                                    ? 'response'
                                    : (_transcription ?? _statusIdx),
                              ),
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
                    onSend: _sendToGuide,
                    onRecordStart: _startRecording,
                    onRecordEnd: _stopRecording,
                    isRecording: _isRecording,
                  ),

                  const SizedBox(height: 16),
                ],
              ),

              // ── Settings overlay ────────────────────────────────────────
              if (_overlay == _DashboardOverlay.settings)
                _OverlaySheet(
                  onClose: () =>
                      setState(() => _overlay = _DashboardOverlay.none),
                  child: StreamBuilder<UserProfile?>(
                    stream: _profileStream,
                    builder: (context, snap) {
                      final profile = snap.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Your practice', style: HgText.eyebrow()),
                          const SizedBox(height: 16),
                          if (profile == null)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            SettingsLetter(
                              displayName: profile.displayName,
                              email: profile.email,
                              practiceLevel: profile.practiceLevel,
                              sessionDuration: profile.sessionDuration,
                              remindersEnabled: profile.remindersEnabled,
                              practiceTime: profile.practiceTime,
                              onChangeName: () => _editField(
                                context,
                                'Name',
                                profile.displayName,
                                'displayName',
                              ),
                              onChangeEmail: () => _editField(
                                context,
                                'Email',
                                profile.email,
                                'email',
                              ),
                              onChangeLevel: () =>
                                  _editLevel(context, profile.practiceLevel),
                              onChangeDuration: () => _editField(
                                context,
                                'Session duration',
                                profile.sessionDuration,
                                'sessionDuration',
                              ),
                              onToggleReminders: () =>
                                  _toggleReminders(profile.remindersEnabled),
                              onChangePracticeTime: () => _editPracticeTime(
                                context,
                                profile.practiceTime,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

              // ── Asana player overlay ────────────────────────────────────
              if (_overlay == _DashboardOverlay.asana)
                _OverlaySheet(
                  onClose: () =>
                      setState(() => _overlay = _DashboardOverlay.none),
                  child: AsanaPlayer(onSessionComplete: _recordSession),
                ),

              // ── Progress journal overlay ─────────────────────────────────
              if (_overlay == _DashboardOverlay.journal)
                _OverlaySheet(
                  onClose: () =>
                      setState(() => _overlay = _DashboardOverlay.none),
                  child: ProgressJournal(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                  ),
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
                  onJournal: () => setState(() {
                    _menuOpen = false;
                    _overlay = _DashboardOverlay.journal;
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
  final void Function(String) onSend;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;
  final bool isRecording;

  const _TypeComposer({
    required this.onSend,
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.isRecording,
  });

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTapDown: (_) => widget.onRecordStart(),
                onTapUp: (_) => widget.onRecordEnd(),
                onTapCancel: widget.onRecordEnd,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: widget.isRecording
                        ? const RecordingPulse(size: 10)
                        : Icon(
                            Icons.mic_none_rounded,
                            color: HgColors.cream.withValues(alpha: 0.7),
                            size: 20,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                  final text = _ctrl.text.trim();
                  if (text.isNotEmpty) {
                    widget.onSend(text);
                    _ctrl.clear();
                  }
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
  final VoidCallback onJournal;

  const _DashboardMenu({
    required this.onClose,
    required this.onSettings,
    required this.onAsana,
    required this.onJournal,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Today\'s practice', onAsana),
      ('Progress journal', onJournal),
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
