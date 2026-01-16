import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onSignInAsGuest;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const WelcomeScreen({
    super.key,
    required this.onSignInAsGuest,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // ignore: unused_local_variable
    final appState = AppStateScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),

                        // LOGO (fixed sensible size)
                        Center(
                          child: Image.asset(
                            theme.brightness == Brightness.dark
                                ? 'assets/branding/agu_logo_dark.png'
                                : 'assets/branding/agu_logo_light.png',
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Welcome to REZON',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Modern streetwear for confident everyday wear',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.dark_mode_outlined, size: 18),
                            const SizedBox(width: 6),
                            const Text('Dark'),
                            Switch.adaptive(
                              value: widget.themeMode == ThemeMode.dark,
                              onChanged: (v) => widget.onThemeModeChanged(
                                v ? ThemeMode.dark : ThemeMode.light,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // EMAIL
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),

                        const SizedBox(height: 12),

                        // PASSWORD
                        TextField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),

                        const SizedBox(height: 12),

                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: theme.colorScheme.error),
                          ),

                        const SizedBox(height: 16),

                        // SIGN IN
                        OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  setState(() {
                                    _loading = true;
                                    _errorMessage = null;
                                  });
                                  try {
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                      email:
                                          _emailController.text.trim(),
                                      password:
                                          _passwordController.text,
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    setState(() =>
                                        _errorMessage = e.message);
                                  } finally {
                                    setState(() => _loading = false);
                                  }
                                },
                          child: _loading
                              ? const CircularProgressIndicator()
                              : const Text('Sign in'),
                        ),

                        const SizedBox(height: 12),

                        // REGISTER
                        OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  setState(() {
                                    _loading = true;
                                    _errorMessage = null;
                                  });
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                      email:
                                          _emailController.text.trim(),
                                      password:
                                          _passwordController.text,
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    setState(() =>
                                        _errorMessage = e.message);
                                  } finally {
                                    setState(() => _loading = false);
                                  }
                                },
                          child: _loading
                              ? const CircularProgressIndicator()
                              : const Text('Register'),
                        ),

                        const SizedBox(height: 12),

                        // GUEST
                        OutlinedButton.icon(
                          onPressed: widget.onSignInAsGuest,
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Sign in as guest'),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}