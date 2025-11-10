import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'signup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 32,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  _initialsForName(state.userName),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      state.userName,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.userGender == null
                          ? 'Tell us a little about yourself'
                          : 'Gender: ${state.userGender}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (BuildContext context) => const SignUpScreen()),
                    );
                  },
                  child: Text(state.isProfileComplete ? 'Edit profile' : 'Complete profile'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Quick stats', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _StatsRow(state: state),
          const SizedBox(height: 24),
          Text('Account settings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _SettingsCard(
            items: const <_SettingItem>[
              _SettingItem(icon: Icons.badge_outlined, title: 'Student ID verification'),
              _SettingItem(icon: Icons.location_on_outlined, title: 'Manage campus pickup spots'),
              _SettingItem(icon: Icons.notifications_outlined, title: 'Alerts & launches'),
              _SettingItem(icon: Icons.security_outlined, title: 'Privacy & security'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatTile(
            label: 'Wishlist',
            value: state.favorites.length.toString(),
            icon: Icons.favorite_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Cart items',
            value: state.cartItems.length.toString(),
            icon: Icons.shopping_cart_checkout_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Collections',
            value: '4',
            icon: Icons.dashboard_customize_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

String _initialsForName(String name) {
  final List<String> parts = name.trim().split(RegExp(r'\s+')).where((String part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    final String word = parts.first;
    if (word.length >= 2) {
      return word.substring(0, 2).toUpperCase();
    }
    return word.substring(0, 1).toUpperCase();
  }
  final String first = parts.first;
  final String last = parts.last;
  final String initials = (first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : '');
  return initials.isEmpty ? '?' : initials.toUpperCase();
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.items});

  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: items
            .map(
              (_SettingItem item) => Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  if (item != items.last)
                    Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SettingItem {
  const _SettingItem({required this.icon, required this.title});

  final IconData icon;
  final String title;
}
