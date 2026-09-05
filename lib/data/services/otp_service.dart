import '../../core/config/app_config.dart';
import 'api_client.dart';

/// Result of an OTP verification.
class OtpResult {
  final bool success;
  final String? token;           // JWT / session token from backend
  final Map<String, dynamic>? user; // user payload if returned
  final String? error;

  const OtpResult({
    required this.success,
    this.token,
    this.user,
    this.error,
  });
}

/// Abstract OTP provider — implemented by AWS backend, Firebase, or mock.
abstract class OtpProvider {
  Future<bool> sendOtp(String phone);
  Future<OtpResult> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  });
}

/// AWS / custom-backend OTP over HTTPS.
/// Backend endpoints expected:
///   POST /auth/send-otp     { phone }               -> { verificationId }
///   POST /auth/verify-otp   { phone, otp, role }     -> { token, user }
class BackendOtpProvider implements OtpProvider {
  final ApiClient _api = ApiClient.instance;
  String? _verificationId;

  @override
  Future<bool> sendOtp(String phone) async {
    try {
      final res = await _api.post('/auth/send-otp', data: {'phone': phone});
      _verificationId = res.data['verificationId']?.toString();
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<OtpResult> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  }) async {
    try {
      final res = await _api.post('/auth/verify-otp', data: {
        'phone': phone,
        'otp': otp,
        'role': role,
        'verificationId': _verificationId,
      });
      if (res.statusCode == 200) {
        return OtpResult(
          success: true,
          token: res.data['token']?.toString(),
          user: res.data['user'] as Map<String, dynamic>?,
        );
      }
      return const OtpResult(success: false, error: 'Verification failed');
    } catch (e) {
      return OtpResult(success: false, error: e.toString());
    }
  }
}

/// Mock provider — accepts any 4-digit OTP except 0000. Used until a
/// backend URL (or Firebase) is configured.
class MockOtpProvider implements OtpProvider {
  @override
  Future<bool> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<OtpResult> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp.length != 4 || otp == '0000') {
      return const OtpResult(success: false, error: 'Invalid OTP');
    }
    return OtpResult(
      success: true,
      token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      user: {
        'id': 'u_${DateTime.now().millisecondsSinceEpoch}',
        'name': role == 'driver' ? 'Arjun Kumar' : 'Rohan Sharma',
        'phone': phone,
        'role': role,
        'isVerified': true,
        'rating': 4.8,
        'totalRides': 28,
        'walletBalance': 320,
      },
    );
  }
}

/// Factory that picks the right provider based on config.
class OtpProviderFactory {
  static OtpProvider create() {
    if (AppConfig.hasBackend) return BackendOtpProvider();
    return MockOtpProvider();
  }
}
