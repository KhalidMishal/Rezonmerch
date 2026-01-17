import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'signup_screen.dart';
import 'campus_map_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.themeMode, required this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

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
                          ? 'Complete your profile?'
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
          // Appearance toggle (separate ListTile so users can toggle quickly)
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            trailing: Switch.adaptive(
              value: themeMode == ThemeMode.dark,
              onChanged: (bool v) => onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light),
            ),
            onTap: () => onThemeModeChanged(themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            items: <_SettingItem>[
              _SettingItem(
                icon: Icons.location_on_outlined,
                title: 'Location',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (BuildContext context) => const CampusMapScreen(
                      mapUrl: 'https://maps.app.goo.gl/fFN8SWV74iJeFGB39',
                    ),
                  ));
                },
              ),
              const _SettingItem(icon: Icons.notifications_outlined, title: 'Alerts & launches'),
              const _SettingItem(icon: Icons.security_outlined, title: 'Privacy & security'),
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

class _SettingsCard extends StatefulWidget {
  const _SettingsCard({required this.items});

  final List<_SettingItem> items;

  @override
  State<_SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<_SettingsCard> {
  static const String _mapUrl = 'https://maps.app.goo.gl/fFN8SWV74iJeFGB39';
  // Embedded iframe HTML to better control appearance inside the preview.
  static const String _mapEmbedHtml = '''
<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>html,body{height:100%;margin:0;}iframe{border:0;width:100%;height:100%;}</style>
  </head>
  <body>
    <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3112.158619586899!2d35.47095907666993!3d38.73712215614412!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x152b118c82226a79%3A0x9e5486f83ee76d46!2sAbdullah%20G%C3%BCl%20University!5e0!3m2!1sen!2str!4v1765628767916!5m2!1sen!2str" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
  </body>
</html>
''';

  WebViewController? _mapController;
  bool _webViewAvailable = true;

  @override
  void initState() {
    super.initState();
    if (WebViewPlatform.instance == null) {
      _webViewAvailable = false;
      _mapController = null;
      return;
    }
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          try {
            final Uri uri = Uri.parse(request.url);
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
          } catch (_) {
            try {
              await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
            } catch (_) {}
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.dataFromString(_mapEmbedHtml, mimeType: 'text/html', encoding: utf8));
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: widget.items
            .map(
              (_SettingItem item) => Column(
                children: <Widget>[
                  if (item.title == 'Alerts & launches')
                    ExpansionTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                      children: <Widget>[
                        SwitchListTile(
                          title: const Text('Completed transactions'),
                          subtitle: const Text('Sent right after a purchase'),
                          value: state.notifyCompletedTransactions,
                          onChanged: (bool v) => state.setNotifyCompletedTransactions(v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Available discounts'),
                          value: state.notifyAvailableDiscounts,
                          onChanged: (bool v) => state.setNotifyAvailableDiscounts(v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('New products'),
                          value: state.notifyNewProducts,
                          onChanged: (bool v) => state.setNotifyNewProducts(v),
                        ),
                      ],
                    )
                  else if (item.title == 'Campus Location')
                    ExpansionTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                      children: <Widget>[
                        SizedBox(
                          height: 200,
                          child: _webViewAvailable && _mapController != null
                              ? WebViewWidget(controller: _mapController!)
                              : InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute<void>(
                                      builder: (BuildContext context) => const CampusMapScreen(mapUrl: _mapUrl),
                                    ));
                                  },
                                  child: Container(
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Icon(Icons.map, size: 36),
                                          const SizedBox(height: 8),
                                          const Text('Open map'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute<void>(
                                  builder: (BuildContext context) => const CampusMapScreen(mapUrl: _mapUrl),
                                ));
                              },
                              child: const Text('Open full map'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: _mapUrl));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
                              },
                              child: const Text('Copy link'),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: item.onTap,
                    ),
                  if (item != widget.items.last)
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
  const _SettingItem({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
}
