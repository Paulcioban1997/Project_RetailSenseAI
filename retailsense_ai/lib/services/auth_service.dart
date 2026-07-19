class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;

  // Demo credentials — change before going to production
  static const String demoEmail = 'demo@retailsenseai.ca';
  static const String demoPassword = 'Demo2024!';

  bool get isAuthenticated => _isAuthenticated;

  bool login(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    if (normalizedEmail == demoEmail && normalizedPassword == demoPassword) {
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
  }
}
