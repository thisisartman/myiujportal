import 'package:flutter_riverpod/flutter_riverpod.dart';

// Hardcoded demo credentials — swap out when real auth is added.
const _demoCredentials = {
  'student@iuj.ac.jp': 'iuj2026',
  'professor@iuj.ac.jp': 'iuj2026',
  'admin@iuj.ac.jp': 'iuj2026',
};

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  /// Returns true on success, false if credentials don't match.
  bool login(String email, String password) {
    final valid = _demoCredentials[email.trim().toLowerCase()] == password;
    if (valid) state = true;
    return valid;
  }

  void logout() => state = false;
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(),
);
