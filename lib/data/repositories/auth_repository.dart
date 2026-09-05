import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/otp_service.dart';

/// Handles OTP request/verify (via pluggable OtpProvider) and session
/// persistence. Works with AWS backend, Firebase, or mock automatically.
class AuthRepository {
  static const _kUserKey  = 'bikejee_user';
  static const _kTokenKey = 'bikejee_token';

  final ApiClient _api = ApiClient.instance;
  final OtpProvider _otp = OtpProviderFactory.create();

  /// Sends OTP to the phone number.
  Future<bool> sendOtp(String phone) => _otp.sendOtp(phone);

  /// Verifies OTP, persists session, returns the authenticated user or null.
  Future<UserModel?> verifyOtp({
    required String phone,
    required String otp,
    required UserRole role,
  }) async {
    final result = await _otp.verifyOtp(
      phone: phone,
      otp: otp,
      role: role.name,
    );

    if (!result.success || result.user == null || result.token == null) {
      return null;
    }

    final user = UserModel.fromJson(result.user!);
    await _persist(user, result.token!);
    return user;
  }

  Future<void> _persist(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
    await prefs.setString(_kTokenKey, token);
    _api.setAuthToken(token);
  }

  /// Restores a saved session on app start. Returns null if none.
  Future<UserModel?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserKey);
    final token = prefs.getString(_kTokenKey);
    if (raw == null || token == null) return null;
    _api.setAuthToken(token);
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
    await prefs.remove(_kTokenKey);
    _api.setAuthToken(null);
  }
}
