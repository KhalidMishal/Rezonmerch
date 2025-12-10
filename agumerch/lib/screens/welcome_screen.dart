import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onSignInAsGuest;
  final VoidCallback onSignInWithGoogle;
  final VoidCallback onRegister;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const WelcomeScreen({
    super.key,
    required this.onSignInAsGuest,
    required this.onSignInWithGoogle,
    required this.onRegister,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      // removed hardcoded backgroundColor so app theme (light/dark) is used
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // simple logo block
              Image.asset(
                theme.brightness == Brightness.dark
                    ? 'assets/branding/agu_logo_dark.png'
                    : 'assets/branding/agu_logo_light.png',
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              // use theme text styles so colors adapt in dark mode
              Text(
                'Welcome to AGÜ Store',
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Browse and buy official AGÜ merch brought to you by students.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              // Appearance toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.dark_mode_outlined),
                  const SizedBox(width: 8),
                  Text('Dark mode', style: textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Switch.adaptive(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (bool v) => onThemeModeChanged(
                      v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Sign in with Google (non-functional placeholder)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSignInWithGoogle,
                  icon: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface, // adapt to theme
                    ),
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Sign in with Google',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 16.0,
                    ),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sign in as guest (navigates into app)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSignInAsGuest,
                  icon: Icon(
                    Icons.person_outline,
                    color: theme.iconTheme.color,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Sign in as guest',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 16.0,
                    ),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onRegister,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 16.0,
                    ),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'Register',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 15),
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
