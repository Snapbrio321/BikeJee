import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/role_select_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/driver/screens/driver_welcome_screen.dart';
import 'features/driver/screens/driver_create_profile_screen.dart';
import 'features/customer/screens/customer_shell.dart';
import 'features/driver/screens/driver_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const BikeJeeApp());
}

class BikeJeeApp extends StatelessWidget {
  const BikeJeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BikeJee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppNavigator(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Central app-level state-machine navigator — NO inner Navigator wrappers.
// All back navigation uses explicit callbacks, preventing blank-screen bugs.
// ─────────────────────────────────────────────────────────────────────────────
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  _AppScreen _screen = _AppScreen.splash;
  String _role = '';
  String _phone = '';

  void _go(_AppScreen s) => setState(() => _screen = s);

  // Determine the correct "back" destination from each screen
  void _goBack() {
    switch (_screen) {
      case _AppScreen.login:
        _go(_role == 'driver' ? _AppScreen.driverWelcome : _AppScreen.roleSelect);
        break;
      case _AppScreen.otp:
        _go(_AppScreen.login);
        break;
      case _AppScreen.driverCreateProfile:
        _go(_AppScreen.otp);
        break;
      case _AppScreen.driverWelcome:
        _go(_AppScreen.roleSelect);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(
        key: ValueKey(_screen),
        child: _buildScreen(),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case _AppScreen.splash:
        return SplashScreen(onDone: () => _go(_AppScreen.onboarding));

      case _AppScreen.onboarding:
        return OnboardingScreen(onDone: () => _go(_AppScreen.roleSelect));

      case _AppScreen.roleSelect:
        return RoleSelectScreen(
          onRoleSelected: (role) {
            _role = role;
            _go(role == 'driver'
                ? _AppScreen.driverWelcome
                : _AppScreen.login);
          },
        );

      case _AppScreen.driverWelcome:
        return DriverWelcomeScreen(
          onLogin: () => _go(_AppScreen.login),
          onBack: _goBack,
        );

      case _AppScreen.login:
        return LoginScreen(
          role: _role,
          onBack: _goBack,
          onOtpSent: (phone) {
            _phone = phone;
            _go(_AppScreen.otp);
          },
        );

      case _AppScreen.otp:
        return OtpScreen(
          phone: _phone,
          role: _role,
          onBack: _goBack,
          onVerified: () => _go(
            _role == 'driver'
                ? _AppScreen.driverCreateProfile
                : _AppScreen.customerHome,
          ),
        );

      case _AppScreen.driverCreateProfile:
        return DriverCreateProfileScreen(
          onBack: _goBack,
          onDone: () => _go(_AppScreen.driverHome),
        );

      case _AppScreen.customerHome:
        return CustomerShell(
          onLogout: () => _go(_AppScreen.roleSelect),
        );

      case _AppScreen.driverHome:
        return DriverShell(
          onLogout: () => _go(_AppScreen.roleSelect),
        );
    }
  }
}

enum _AppScreen {
  splash,
  onboarding,
  roleSelect,
  driverWelcome,
  login,
  otp,
  driverCreateProfile,
  customerHome,
  driverHome,
}
