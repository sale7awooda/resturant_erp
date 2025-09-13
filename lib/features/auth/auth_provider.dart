import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_dao.dart';
import 'auth_models.dart';

/// Provides the singleton AuthService instance as a Riverpod provider
final authProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  List<String> _permissions = [];

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Current logged-in user
  UserModel? get user => _currentUser;

  /// True if a user is logged in
  bool get loggedIn => _currentUser != null;

  /// Cached permissions for the current user
  List<String> get permissions => List.unmodifiable(_permissions);

  /// Load user by ID (e.g., app start persistence)
  Future<void> loadUserById(int id) async {
    final user = await AuthDao.getUserById(id);
    if (user != null) {
      _currentUser = user;
      await _loadPermissions();
    } else {
      _currentUser = null;
      _permissions = [];
    }
    notifyListeners();
  }

  /// Login by username and password
  Future<bool> login({required String username, required String password}) async {
    final authenticated = await AuthDao.authenticate(username, password);
    if (!authenticated) return false;

    final user = await AuthDao.getUserByUsername(username);
    if (user != null) {
      _currentUser = user;
      await _loadPermissions();
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Register a new user
  /// Does NOT automatically log in
  Future<int> register({
    required String username,
    String? email,
    required String password,
    int? roleId,
  }) async {
    return await AuthDao.registerUser(
      username: username,
      email: email,
      password: password,
      roleId: roleId,
    );
  }

  /// Logout current user
  Future<void> logout() async {
    _currentUser = null;
    _permissions = [];
    notifyListeners();
  }

  /// Reload role permissions for current user
  Future<void> _loadPermissions() async {
    if (_currentUser == null) {
      _permissions = [];
      return;
    }

    final role = await AuthDao.getRoleById(_currentUser!.roleId ?? -1);
    if (role == null || role.permissions == null || role.permissions!.isEmpty) {
      _permissions = [];
    } else {
      _permissions = AuthDao.parsePermissions(role.permissions!);
    }
  }

  /// Check if the current user has a specific permission
  /// Uses cached permissions
  bool hasPermission(String permissionKey) {
    if (!loggedIn) return false;
    return _permissions.contains(permissionKey);
  }
}
