import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../data/models/place_model.dart';
import '../../../providers/ride_provider.dart';
import '../../../providers/bookings_provider.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'wallet_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import 'book_ride_screen.dart';
import 'finding_driver_screen.dart';
import 'live_tracking_screen.dart';
import 'ride_completed_screen.dart';
import 'parcel_delivery_screen.dart';
import 'parcel_tracking_screen.dart';

// RideOptionsScreen removed from flow — Rapido-style: Home → Book directly

class CustomerShell extends StatefulWidget {
  final VoidCallback? onLogout;
  const CustomerShell({super.key, this.onLogout});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _navIndex = 0;

  /// Flow state machine — no Navigator stack
  String _flowState = 'home';

  /// Carries context through the flow (service type + destination)
  String _bookingService     = 'Bike';
  String _bookingDestination = '';   // display name for the book screen

  /// Back-navigation history stack
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
    setState(() {
      _flowState = 'home';
      _bookingService     = 'Bike';
      _bookingDestination = '';
    });
  }

  // On "Done": save the completed ride to bookings history, then reset.
  void _finishRide() {
    final ride = context.read<RideProvider>();
    if (ride.activeRide != null) {
      context.read<BookingsProvider>().addCompleted(ride.activeRide!);
    }
    ride.reset();
    _resetFlow();
  }

  // Called from HomeScreen when user taps a place suggestion.
  // The resolved PlaceModel (with coords) is already in RideProvider.setDrop.
  void _startBooking(String service, PlaceModel destination) {
    _bookingService     = service;
    _bookingDestination = destination.name;
    if (service == 'Parcel') {
      _navigate('parcel');
    } else {
      _navigate('bookRide'); // Skip RideOptions — go straight to map+fare
    }
  }

  Widget _buildFlow() {
    switch (_flowState) {
      // ── Rapido-style: directly on map with fare ─────────────────────────
      case 'bookRide':
        return BookRideScreen(
          service:     _bookingService,
          destination: _bookingDestination,
          onBooked:    () => _navigate('findingDriver'),
          onBack:      _goBack,
        );
      case 'findingDriver':
        return FindingDriverScreen(
          onDriverFound: () => _navigate('tracking'),
          onCancelled:   _resetFlow,
        );
      case 'tracking':
        return LiveTrackingScreen(
          onRideCompleted: () => _navigate('completed'),
          onCancelled:     _resetFlow,
        );
      case 'completed':
        return RideCompletedScreen(onDone: _finishRide);

      // ── Parcel flow ─────────────────────────────────────────────────────
      case 'parcel':
        return ParcelDeliveryScreen(
          onBooked: () => _navigate('parcelTracking'),
          onBack:   _goBack,
        );
      case 'parcelTracking':
        return ParcelTrackingScreen(onBack: _goBack);

      // ── Main tabs ───────────────────────────────────────────────────────
      default:
        return _buildMain();
    }
  }

  Widget _buildMain() {
    switch (_navIndex) {
      case 0:
        return CustomerHomeScreen(
          onBookRide: _startBooking,   // (service, destination) → direct to map
          onParcel:   () => _navigate('parcel'),
        );
      case 1:
        return const MyBookingsScreen();
      case 2:
        return const WalletScreen();
      case 3:
        return const OffersScreen();
      case 4:
        return CustomerProfileScreen(onLogout: widget.onLogout);
      default:
        return CustomerHomeScreen(
          onBookRide: _startBooking,
          onParcel:   () => _navigate('parcel'),
        );
    }
  }

  bool get _flowIsHome => _flowState == 'home';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_flowIsHome) _goBack();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
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
            ? CustomerBottomNav(
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
