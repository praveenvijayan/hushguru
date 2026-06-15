import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/hg_button.dart';
import '../widgets/hg_input.dart';
import '../widgets/wordmark.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, @visibleForTesting this.createAccount});

  @visibleForTesting
  final Future<void> Function(String email, String password)? createAccount;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (widget.createAccount != null) {
        await widget.createAccount!(email, password);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // Auth state change in app.dart routes to OnboardingScreen automatically.
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Registration failed.');
    } catch (_) {
      setState(() => _error = 'Registration failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HgColors.shell,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: HgColors.navy),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(child: HgWordmark(size: 17, color: HgColors.navy)),
              const SizedBox(height: 48),
              Text('Create account', style: HgText.h1()),
              const SizedBox(height: 6),
              Text(
                'Start your practice journey.',
                style: HgText.body(color: HgColors.ink60),
              ),
              const SizedBox(height: 36),
              HgInput(
                label: 'Email address',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              HgInput(
                label: 'Password',
                controller: _passwordCtrl,
                obscure: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: HgText.caption(color: HgColors.coral)),
              ],
              const SizedBox(height: 28),
              HgButton(
                label: _loading ? 'Creating account…' : 'Create account',
                onTap: _loading ? null : _register,
              ),
              const SizedBox(height: 48),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
