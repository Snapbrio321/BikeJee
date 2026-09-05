import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import '../data/services/api_client.dart';
import '../data/services/payment_service.dart';

class WalletTransaction {
  final String id;
  final String label;
  final int amount;      // +credit / -debit (rupees)
  final DateTime time;
  final bool isCredit;

  const WalletTransaction({
    required this.id,
    required this.label,
    required this.amount,
    required this.time,
    required this.isCredit,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> j) => WalletTransaction(
        id: j['id']?.toString() ?? '',
        label: j['label'] ?? '',
        amount: j['amount'] ?? 0,
        time: DateTime.tryParse(j['time']?.toString() ?? '') ?? DateTime.now(),
        isCredit: (j['amount'] ?? 0) >= 0,
      );
}

class WalletProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;
  final PaymentService _payment = PaymentService();

  double _balance = 320;
  bool _processing = false;
  final List<WalletTransaction> _transactions = [
    WalletTransaction(id: '1', label: 'Added Money', amount: 200,
        time: DateTime.now().subtract(const Duration(hours: 3)), isCredit: true),
    WalletTransaction(id: '2', label: 'Ride Payment', amount: -45,
        time: DateTime.now().subtract(const Duration(hours: 5)), isCredit: false),
    WalletTransaction(id: '3', label: 'Referral Bonus', amount: 50,
        time: DateTime.now().subtract(const Duration(days: 1)), isCredit: true),
    WalletTransaction(id: '4', label: 'Parcel Payment', amount: -60,
        time: DateTime.now().subtract(const Duration(days: 2)), isCredit: false),
  ];

  double get balance => _balance;
  bool get processing => _processing;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  /// Loads balance + history from backend (if configured).
  Future<void> load() async {
    if (!AppConfig.hasBackend) return;
    try {
      final res = await _api.get('/wallet');
      _balance = (res.data['balance'] as num?)?.toDouble() ?? _balance;
      final txs = (res.data['transactions'] as List?) ?? [];
      _transactions
        ..clear()
        ..addAll(txs.map((t) => WalletTransaction.fromJson(t)));
      notifyListeners();
    } catch (_) {}
  }

  /// Adds money via Razorpay (or mock). Returns true on success.
  Future<bool> addMoney(int amount, {String contact = '', String email = ''}) async {
    _processing = true;
    notifyListeners();

    final result = await _payment.pay(
      amountRupees: amount,
      description: 'Add ₹$amount to BikeJee Wallet',
      contact: contact,
      email: email,
    );

    if (result.success) {
      _balance += amount;
      _transactions.insert(0, WalletTransaction(
        id: result.paymentId ?? DateTime.now().toString(),
        label: 'Added Money',
        amount: amount,
        time: DateTime.now(),
        isCredit: true,
      ));
    }

    _processing = false;
    notifyListeners();
    return result.success;
  }

  /// Deducts a ride/parcel fare from the wallet.
  bool payFromWallet(int amount, String label) {
    if (_balance < amount) return false;
    _balance -= amount;
    _transactions.insert(0, WalletTransaction(
      id: DateTime.now().toString(),
      label: label,
      amount: -amount,
      time: DateTime.now(),
      isCredit: false,
    ));
    notifyListeners();
    return true;
  }

  /// Withdraw (driver side).
  Future<bool> withdraw(int amount) async {
    if (_balance < amount) return false;
    _processing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _balance -= amount;
    _transactions.insert(0, WalletTransaction(
      id: DateTime.now().toString(),
      label: 'Withdrawal',
      amount: -amount,
      time: DateTime.now(),
      isCredit: false,
    ));
    _processing = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _payment.dispose();
    super.dispose();
  }
}
