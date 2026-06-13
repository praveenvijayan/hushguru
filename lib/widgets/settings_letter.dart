import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SettingsLetter extends StatelessWidget {
  final String displayName;
  final String email;
  final String practiceLevel;
  final String sessionDuration;
  final VoidCallback? onChangeName;
  final VoidCallback? onChangeEmail;
  final VoidCallback? onChangeLevel;
  final VoidCallback? onChangeDuration;

  const SettingsLetter({
    super.key,
    this.displayName = 'Praveen',
    this.email = 'praveen@example.com',
    this.practiceLevel = 'intermediate',
    this.sessionDuration = '20 minutes',
    this.onChangeName,
    this.onChangeEmail,
    this.onChangeLevel,
    this.onChangeDuration,
  });

  TextSpan _tappable(String text, VoidCallback? onTap) {
    return TextSpan(
      text: text,
      style: HgText.body(color: HgColors.coral).copyWith(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: HgColors.coral,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  TextSpan _plain(String text) {
    return TextSpan(
      text: text,
      style: HgText.body(color: HgColors.ink80),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          _plain('Dear '),
          _tappable(displayName, onChangeName),
          _plain(',\n\nYour practice is set to '),
          _tappable(practiceLevel, onChangeLevel),
          _plain(' level with sessions lasting '),
          _tappable(sessionDuration, onChangeDuration),
          _plain('. We send your reflections to '),
          _tappable(email, onChangeEmail),
          _plain(
            '.\n\nBreath by breath, we are building something meaningful together.',
          ),
        ],
      ),
    );
  }
}
