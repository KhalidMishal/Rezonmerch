import 'package:flutter/material.dart';

import '../state/app_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) {
      return;
    }
    final AppState state = AppStateScope.of(context);
    if (state.userName != 'Guest') {
      _nameController.text = state.userName;
    }
    _selectedGender = state.userGender;
    _prefilled = true;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final AppState state = AppStateScope.of(context);
    state.setUserProfile(name: _nameController.text.trim(), gender: _selectedGender!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: <Widget>[
              Text('Let us know who you are', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                "We'll use this information to personalize your AGU Merch experience.",
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                items: const <String>['Female', 'Male', 'Non-binary', 'Prefer not to say']
                    .map(
                      (String option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) => setState(() => _selectedGender = value),
                validator: (String? value) => value == null ? 'Please select a gender' : null,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _handleSubmit,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save profile'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
