import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:coursebuddy/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: size.width > 400 ? 350 : size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/coursebuddy_logo.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Learn. Build. Succeed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AbsorbPointer(
                      absorbing: _busy,
                      child: Opacity(
                        opacity: _busy ? 0.6 : 1,
                        child: SignInButton(
                          Buttons.google,
                          text: _busy ? "Signing in..." : "Sign in with Google",
                          onPressed: () async {
                            if (_busy) return;
                            setState(() => _busy = true);
                            await _authService.signInWithGoogle(
                              context,
                              mounted: mounted,
                            );
                            if (!mounted) return;
                            setState(() => _busy = false);
                          },
                        ),
                      ),
                    ),
                    if (_busy) const SizedBox(height: 12),
                    if (_busy) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
