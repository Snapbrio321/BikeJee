import 'package:flutter/material.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import 'driver_dashboard_screen.dart';
import 'driver_earnings_screen.dart';
import 'driver_wallet_screen.dart';
import 'driver_subscription_screen.dart';
import 'driver_ride_flow_screen.dart';
import 'driver_profile_screen.dart';
import '../../customer/screens/help_support_screen.dart';

class DriverShell extends StatefulWidget {
  final VoidCallback? onLogout;
  const DriverShell({super.key, this.onLogout});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _navIndex = 0;
  String _flowState = 'home';
  final List<String> _history = [];

  void _navigate(String state) {
    _history.add(_flowState);
    setState(() => _flowState = state);
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() => _flowState = _history.removeLast());
    } else {
      setState(() => _flowState = 'home');
    }
  }

  void _resetFlow() {
    _history.clear();
    setState(() => _flowState = 'home');
  }

  bool get _flowIsHome => _flowState == 'home';

  Widget _buildFlow() {
    switch (_flowState) {
      case 'subscription':
        return DriverSubscriptionScreen(
          onActivated: _resetFlow,
          onBack: _goBack,
        );
      case 'rideFlow':
        return DriverRideFlowScreen(
          onRideCompleted: _resetFlow,
          onDeclined: _resetFlow,
        );
      default:
        return _buildMain();
    }
  }

  Widget _buildMain() {
    switch (_navIndex) {
      case 0:
        return DriverDashboardScreen(
          onSubscribe: () => _navigate('subscription'),
          onNewRide: () => _navigate('rideFlow'),
        );
      case 1:
        return const DriverEarningsScreen();
      case 2:
        return const DriverWalletScreen();
      case 3:
        return const HelpSupportScreen();
      case 4:
        return DriverProfileScreen(onLogout: widget.onLogout);
      default:
        return DriverDashboardScreen(
          onSubscribe: () => _navigate('subscription'),
          onNewRide: () => _navigate('rideFlow'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_flowIsHome) _goBack();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: KeyedSubtree(
            key: ValueKey('$_flowState$_navIndex'),
            child: _buildFlow(),
          ),
        ),
        bottomNavigationBar: _flowIsHome
            ? DriverBottomNav(
                currentIndex: _navIndex,
                onTap: (i) => setState(() {
                  _navIndex = i;
                  _flowState = 'home';
                  _history.clear();
                }),
              )
            : null,
      ),
    );
  }
}
