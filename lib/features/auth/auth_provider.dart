import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/features/auth/auth_models.dart';
import 'auth_dao.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final valid = await AuthDAO.validateLogin(email, password);
    if (!valid) {
      state = state.copyWith(isLoading: false, error: 'Invalid credentials');
      return;
    }

    final userMap = await AuthDAO.getUserByEmail(email);
    final user = UserModel.fromMap(userMap!);
    state = state.copyWith(user: user, isLoading: false);
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
