import 'package:supabase_flutter/supabase_flutter.dart';

/// Account operations. Accounts live in Supabase Auth; the game server only sees the access token.
abstract class AuthService {
  /// A valid access token for the saved session, refreshing it if expired; null if signed out.
  Future<String?> currentAccessToken();

  /// Returns the access token. Throws with a readable message on failure.
  Future<String> signIn(String email, String password);

  /// Returns the access token, or null if the account must be confirmed by email first.
  Future<String?> signUp(String email, String password);

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  @override
  Future<String?> currentAccessToken() async {
    final session = _auth.currentSession;
    if (session == null) return null;
    if (!session.isExpired) return session.accessToken;
    try {
      final refreshed = await _auth.refreshSession();
      return refreshed.session?.accessToken;
    } on AuthException {
      return null;
    }
  }

  @override
  Future<String> signIn(String email, String password) async {
    final response = await _auth.signInWithPassword(email: email, password: password);
    final token = response.session?.accessToken;
    if (token == null) {
      throw const AuthException('No session returned');
    }
    return token;
  }

  @override
  Future<String?> signUp(String email, String password) async {
    final response = await _auth.signUp(email: email, password: password);
    return response.session?.accessToken;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
