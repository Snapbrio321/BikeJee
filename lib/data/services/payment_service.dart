import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/config/app_config.dart';
import 'api_client.dart';

/// Result of a payment attempt.
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? error;

  const PaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.error,
  });
}

/// Wraps Razorpay checkout. Secure flow:
///   1. backend POST /payments/create-order → { orderId }
///   2. open Razorpay checkout with that orderId
///   3. backend POST /payments/verify verifies signature
///
/// In mock mode (no key) it simulates a successful payment.
class PaymentService {
  final ApiClient _api = ApiClient.instance;
  Razorpay? _razorpay;
  Completer<PaymentResult>? _completer;

  /// Pays [amountRupees] for a ride or wallet top-up.
  /// [description] shows on the checkout sheet.
  Future<PaymentResult> pay({
    required int amountRupees,
    required String description,
    String contact = '',
    String email = '',
  }) async {
    // ── Mock mode ──────────────────────────────────────────────────────────
    if (!AppConfig.hasPayments) {
      await Future.delayed(const Duration(milliseconds: 900));
      return PaymentResult(
        success: true,
        paymentId: 'mock_pay_${DateTime.now().millisecondsSinceEpoch}',
        orderId: 'mock_order',
      );
    }

    // ── Real Razorpay flow ──────────────────────────────────────────────────
    _completer = Completer<PaymentResult>();

    try {
      // 1. Create order on backend (amount in paise)
      String? orderId;
      if (AppConfig.hasBackend) {
        final res = await _api.post('/payments/create-order', data: {
          'amount': amountRupees * 100,
          'currency': 'INR',
          'description': description,
        });
        orderId = res.data['orderId']?.toString();
      }

      // 2. Open checkout
      _razorpay = Razorpay();
      _razorpay!
        ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
        ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
        ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

      _razorpay!.open({
        'key': AppConfig.razorpayKey,
        'amount': amountRupees * 100, // paise
        'name': AppConfig.appName,
        'description': description,
        'currency': 'INR',
        if (orderId != null) 'order_id': orderId,
        'prefill': {'contact': contact, 'email': email},
        'theme': {'color': '#00B14F'},
      });

      final result = await _completer!.future;
      return result;
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }

  Future<void> _onSuccess(PaymentSuccessResponse r) async {
    // 3. Verify signature on backend (critical for security)
    bool verified = true;
    if (AppConfig.hasBackend) {
      try {
        final res = await _api.post('/payments/verify', data: {
          'orderId': r.orderId,
          'paymentId': r.paymentId,
          'signature': r.signature,
        });
        verified = res.data['verified'] == true;
      } catch (_) {
        verified = false;
      }
    }
    _finish(PaymentResult(
      success: verified,
      paymentId: r.paymentId,
      orderId: r.orderId,
      error: verified ? null : 'Signature verification failed',
    ));
  }

  void _onError(PaymentFailureResponse r) {
    _finish(PaymentResult(success: false, error: r.message ?? 'Payment failed'));
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    // handled by Razorpay UI; no-op
  }

  void _finish(PaymentResult result) {
    _razorpay?.clear();
    _razorpay = null;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(result);
    }
  }

  void dispose() {
    _razorpay?.clear();
  }
}
