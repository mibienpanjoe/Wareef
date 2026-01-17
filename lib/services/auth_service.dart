import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Add your Google Client ID here
    clientId:
        '74084374684-t1mh1duig5dg3mjigold22mhe10goqa1.apps.googleusercontent.com',
  );

  // Register with email and password
  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/register', {
      'fullname': fullname,
      'email': email,
      'password': password,
    });

    final data = _apiService.handleResponse(response);

    // Store token
    if (data['token'] != null) {
      await _saveToken(data['token']);
    }

    return data as Map<String, dynamic>;
  }

  // Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final data = _apiService.handleResponse(response);

    // Store token
    if (data['token'] != null) {
      await _saveToken(data['token']);
    }

    return data as Map<String, dynamic>;
  }

  // Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Send token to backend
      final response = await _apiService.post('/auth/google', {
        'token': googleAuth.idToken,
      });

      final data = _apiService.handleResponse(response);

      // Store token
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }

      return data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      // Google sign out failed or not supported
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      return _apiService.handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullname,
    String? imagePath,
  }) async {
    try {
      final response = await _apiService.updateProfile(
        fullname: fullname,
        imagePath: imagePath,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Save token to local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
}
