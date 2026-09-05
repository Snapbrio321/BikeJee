import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, unauthenticated, otpSent, authenticated, loading }

/// Central auth state. Screens read this via context.watch/read.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String _phone = '';
  UserRole _pendingRole = UserRole.customer;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get phone => _phone;
  UserRole get pendingRole => _pendingRole;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isDriver => _user?.role == UserRole.driver;

  /// Try to restore a saved session at startup.
  Future<void> bootstrap() async {
    final user = await _repo.restoreSession();
    if (user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void setRole(UserRole role) {
    _pendingRole = role;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _phone = phone;
    _error = null;
    _setStatus(AuthStatus.loading);
    final ok = await _repo.sendOtp(phone);
    if (ok) {
      _setStatus(AuthStatus.otpSent);
    } else {
      _error = 'Failed to send OTP. Please try again.';
      _setStatus(AuthStatus.unauthenticated);
    }
    return ok;
  }

  Future<bool> verifyOtp(String otp) async {
    _error = null;
    _setStatus(AuthStatus.loading);
    final user = await _repo.verifyOtp(
      phone: _phone,
      otp: otp,
      role: _pendingRole,
    );
    if (user != null) {
      _user = user;
      _setStatus(AuthStatus.authenticated);
      return true;
    } else {
      _error = 'Invalid OTP. Please try again.';
      _setStatus(AuthStatus.otpSent);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _phone = '';
    _setStatus(AuthStatus.unauthenticated);
  }

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  void _setStatus(AuthStatus s) {
    _status = s;
    notifyListeners();
  }
}
