
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/supabase_config.dart';

// class AuthService {
//   final _client = SupabaseConfig.client;

//   Future<AuthResponse> signUp(String email, String password) {
//     return _client.auth.signUp(email: email, password: password);
//   }

//   Future<AuthResponse> login(String email, String password) {
//     return _client.auth.signInWithPassword(email: email, password: password);
//   }

//   Future<void> resetPassword(String email) async {
//     await _client.auth.resetPasswordForEmail(email);
//   }

//   Future<void> signOut() async {
//     await _client.auth.signOut();
//   }

//   User? get currentUser => _client.auth.currentUser;
// }
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  Future<void> login(String email, String password) async {
    try {
      EasyLoading.show(status: 'Logging in...');
      final res = await supabase.auth.signInWithPassword(email: email, password: password);
      if (res.user != null) {
        
        EasyLoading.showSuccess('Login successful');
      }
    } catch (e) {
      EasyLoading.showError('Login failed');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      EasyLoading.show(status: 'Signing up...');
      await supabase.auth.signUp(email: email, password: password);
      EasyLoading.showSuccess('Check your email to confirm');
    } catch (e) {
      EasyLoading.showError('Sign up failed');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      EasyLoading.show(status: 'Sending reset link...');
      await supabase.auth.resetPasswordForEmail(email);
      EasyLoading.showSuccess('Check your email');
    } catch (e) {
      EasyLoading.showError('Failed to send link');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
