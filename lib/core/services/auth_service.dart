import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  // ---------------------------------------------------------------------------
  // Social Auth
  // ---------------------------------------------------------------------------

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    // IMPORTANTE: Reemplaza estos IDs con los de tu proyecto en Google Cloud Console
    const webClientId = '178992933358-tl2iim1j095upne9o309t0bsv2dm7c6l.apps.googleusercontent.com'; 
    const iosClientId = 'TU_IOS_CLIENT_ID_AQUI';
    
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? iosClientId : null, // En Android, NO se debe enviar el webClientId aquí
      serverClientId: webClientId,
    );
    
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw 'Inicio de sesión con Google cancelado.';
    }
    
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No se pudo obtener el Access Token de Google.';
    }
    if (idToken == null) {
      throw 'No se pudo obtener el ID Token de Google.';
    }

    return Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw 'El inicio de sesión con Apple solo está disponible en iOS/macOS.';
    }
    
    // Generamos un nonce para evitar ataques de repetición
    final rawNonce = Supabase.instance.client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw 'No se pudo obtener el token de Apple.';
    }

    return Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }
}
