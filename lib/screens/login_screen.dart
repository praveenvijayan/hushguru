import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/hg_button.dart';
import '../widgets/hg_input.dart';
import '../widgets/wordmark.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

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
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password field
              const HgInput(label: 'Password', obscure: true),

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

              const SizedBox(height: 28),

              // Sign in button
              HgButton(label: 'Sign in', onTap: onLoginSuccess),

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
