import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralised authentication service wrapping Supabase Auth.
///
/// Exposes [currentUser] and [isAuthenticated] to read the current session
/// synchronously.  Auth state changes are pushed through Supabase's
/// [onAuthStateChange] stream internally — the GoRouter redirect guard
/// reads the synchronous getters on each navigation event.
class AuthService {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// The currently signed-in user, or `null` when logged out.
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  StreamSubscription<AuthState>? _authSubscription;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Must be called once after [Supabase.initialize].
  void init() {
    // Guard: prevent duplicate subscriptions on hot reload.
    if (_authSubscription != null) return;

    // Sync the current session immediately.
    _currentUser = Supabase.instance.client.auth.currentUser;

    // React to future changes (login, logout, token refresh, …).
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(_onAuthChanged);
  }

  void _onAuthChanged(AuthState state) {
    _currentUser = state.session?.user;
  }

  /// Release resources (rarely needed in production).
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Sign in with email & password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Create a new account with email & password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    // The auth state listener will clear [_currentUser] automatically.
  }

  /// Refresh the session manually (called automatically by the SDK on expiry).
  Future<AuthResponse?> refreshSession() {
    return Supabase.instance.client.auth.refreshSession();
  }

  /// Update the user's password.
  Future<UserResponse> updatePassword(String newPassword) {
    return Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
