import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/hg_button.dart';
import '../widgets/hg_input.dart';
import '../widgets/wordmark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // authStateChanges in app.dart handles navigation
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Sign-in failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HgColors.shell,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 52),

              // Wordmark
              Center(child: HgWordmark(size: 17, color: HgColors.navy)),

              const SizedBox(height: 48),

              // Heading
              Text('Welcome back', style: HgText.h1()),
              const SizedBox(height: 6),
              Text(
                'Your practice continues here.',
                style: HgText.body(color: HgColors.ink60),
              ),

              const SizedBox(height: 36),

              // Email field
              HgInput(
                label: 'Email address',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password field
              HgInput(
                label: 'Password',
                controller: _passwordCtrl,
                obscure: true,
              ),

              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot password?',
                    style: HgText.caption(color: HgColors.coral),
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: HgText.caption(color: HgColors.coral)),
              ],

              const SizedBox(height: 28),

              // Sign in button
              HgButton(
                label: _loading ? 'Signing in…' : 'Sign in',
                onTap: _loading ? null : _signIn,
              ),

              const SizedBox(height: 28),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: HgColors.ink12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: HgText.caption(color: HgColors.ink40),
                    ),
                  ),
                  Expanded(child: Divider(color: HgColors.ink12)),
                ],
              ),

              const SizedBox(height: 28),

              // Google sign-in
              HgButton(
                label: 'Continue with Google',
                variant: HgButtonVariant.outline,
                onTap: () {},
              ),

              const SizedBox(height: 48),

              // Footer
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'New to HushGuru? ',
                          style: HgText.caption(color: HgColors.ink60),
                        ),
                        TextSpan(
                          text: 'Create account',
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
