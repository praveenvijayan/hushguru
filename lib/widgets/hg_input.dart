import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class HgInput extends StatefulWidget {
  final String label;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const HgInput({
    super.key,
    required this.label,
    this.obscure = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<HgInput> createState() => _HgInputState();
}

class _HgInputState extends State<HgInput> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
      style: HgText.body(),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: HgText.bodySmall(
          color: _focused ? HgColors.coral : HgColors.ink60,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: HgColors.ink20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HgColors.coral, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
