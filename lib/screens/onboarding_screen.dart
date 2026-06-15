import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/hg_button.dart';
import '../widgets/hg_input.dart';
import '../widgets/wordmark.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.uid,
    required this.email,
    @visibleForTesting this.signOut,
  });

  final String uid;
  final String email;

  @visibleForTesting
  final Future<void> Function()? signOut;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  String _level = 'intermediate';
  String _duration = '20 minutes';
  bool _saving = false;
  String? _error;

  static const _levels = ['beginner', 'intermediate', 'advanced'];
  static const _durations = [
    '10 minutes',
    '20 minutes',
    '30 minutes',
    '45 minutes',
  ];

  static const _levelLabels = {
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
  };

  static const _durationLabels = {
    '10 minutes': '10 min',
    '20 minutes': '20 min',
    '30 minutes': '30 min',
    '45 minutes': '45 min',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please enter your name to continue.');
        return;
      }
      setState(() {
        _step = 1;
        _error = null;
      });
    } else if (_step == 1) {
      setState(() {
        _step = 2;
        _error = null;
      });
    } else {
      _save();
    }
  }

  Future<void> _escape() async {
    if (widget.signOut != null) {
      await widget.signOut!();
    } else {
      await FirebaseAuth.instance.signOut();
    }
    // Auth-state change in app.dart routes to LoginScreen automatically.
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await UserProfileService.createProfile(
        uid: widget.uid,
        displayName: _nameCtrl.text.trim(),
        email: widget.email,
        practiceLevel: _level,
        sessionDuration: _duration,
      );
      // AppNavigator detects the new profile document and routes to Dashboard.
    } on Exception {
      if (mounted) {
        setState(() {
          _error = 'Unable to save. Please try again.';
          _saving = false;
        });
      }
    }
  }

  Widget _stepDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = _step == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? HgColors.coral : HgColors.ink20,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _optionTile({
    required String value,
    required String label,
    required String current,
    required ValueChanged<String> onSelect,
  }) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => setState(() => onSelect(value)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selected
              ? HgColors.coral
              : Colors.white.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? HgColors.coral : HgColors.ink20,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: HgText.body(color: selected ? HgColors.cream : HgColors.navy),
        ),
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What should we call you?', style: HgText.h1()),
            const SizedBox(height: 8),
            Text(
              'Your name guides your practice journey.',
              style: HgText.body(color: HgColors.ink60),
            ),
            const SizedBox(height: 32),
            HgInput(label: 'Your name', controller: _nameCtrl),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your practice level', style: HgText.h1()),
            const SizedBox(height: 8),
            Text(
              'We\'ll tailor sessions to match where you are.',
              style: HgText.body(color: HgColors.ink60),
            ),
            const SizedBox(height: 32),
            ..._levels.map(
              (l) => _optionTile(
                value: l,
                label: _levelLabels[l]!,
                current: _level,
                onSelect: (v) => _level = v,
              ),
            ),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session duration', style: HgText.h1()),
            const SizedBox(height: 8),
            Text(
              'How long would you like to practice each day?',
              style: HgText.body(color: HgColors.ink60),
            ),
            const SizedBox(height: 32),
            ..._durations.map(
              (d) => _optionTile(
                value: d,
                label: _durationLabels[d]!,
                current: _duration,
                onSelect: (v) => _duration = v,
              ),
            ),
          ],
        );
    }
  }

  String get _buttonLabel {
    if (_step < 2) return 'Continue';
    return _saving ? 'Starting your journey…' : 'Start my practice';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HgColors.shell,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              Center(child: HgWordmark(size: 17, color: HgColors.navy)),
              const SizedBox(height: 32),
              _stepDots(),
              const SizedBox(height: 40),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _stepContent(),
                  ),
                ),
              ),
              if (_error != null) ...[
                Text(_error!, style: HgText.caption(color: HgColors.coral)),
                const SizedBox(height: 12),
              ],
              HgButton(label: _buttonLabel, onTap: _saving ? null : _advance),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _escape();
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: HgText.caption(color: HgColors.ink60),
                        ),
                        TextSpan(
                          text: 'Sign in',
                          style: HgText.caption(color: HgColors.coral),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
