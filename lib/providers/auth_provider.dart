import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { student, faculty, admin }

// Hardcoded demo credentials — swap out when real auth is added.
const _demoCredentials = {
  'student@iuj.ac.jp': 'iuj2026',
  'professor@iuj.ac.jp': 'iuj2026',
  'admin@iuj.ac.jp': 'iuj2026',
};

const _roleMap = {
  'student@iuj.ac.jp': UserRole.student,
  'professor@iuj.ac.jp': UserRole.faculty,
  'admin@iuj.ac.jp': UserRole.admin,
};

class AuthState {
  final bool isLoggedIn;
  final UserRole role;
  final String email;

  const AuthState({
    this.isLoggedIn = false,
    this.role = UserRole.student,
    this.email = '',
  });

  AuthState copyWith({bool? isLoggedIn, UserRole? role, String? email}) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        role: role ?? this.role,
        email: email ?? this.email,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Returns true on success, false if credentials don't match.
  bool login(String email, String password) {
    final e = email.trim().toLowerCase();
    final valid = _demoCredentials[e] == password;
    if (valid) {
      state = AuthState(
        isLoggedIn: true,
        role: _roleMap[e] ?? UserRole.student,
        email: e,
      );
    }
    return valid;
  }

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Convenience: true when any user is logged in.
final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isLoggedIn,
);

/// Convenience: the current user's role.
final userRoleProvider = Provider<UserRole>(
  (ref) => ref.watch(authProvider).role,
);
