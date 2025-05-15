import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sahel_alik/firebase_options.dart';
import 'package:sahel_alik/models/user.dart';
import 'package:sahel_alik/providers/locale_provider.dart';
import 'package:sahel_alik/services/auth_service.dart';
import 'package:sahel_alik/theme/app_theme.dart';
import 'package:sahel_alik/views/interfaces/login_interface.dart';
import 'package:sahel_alik/views/interfaces/register_interface.dart';
import 'package:sahel_alik/views/interfaces/searcher/searcher_home_interface.dart';
import 'package:sahel_alik/views/interfaces/searcher/payment_success_page.dart';
import 'package:sahel_alik/views/interfaces/searcher/payment_error_page.dart';
import 'package:sahel_alik/views/interfaces/splash_screen.dart';

import 'package:sahel_alik/views/interfaces/searcher/booking_screen.dart'; // Import BookingScreen
import 'package:sahel_alik/models/service.dart'; // Import ServiceModel
import 'views/interfaces/provider/provider_home_interface.dart';
import 'views/interfaces/searcher/service_details_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize locale provider
  final localeProvider = LocaleProvider();
  await localeProvider.initLocale();

  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  late AppLinks _appLinks = AppLinks(); // Initialize AppLinks
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(); // Navigator key

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() async {
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      if (!mounted) return;
      print('Error listening to deep links: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    // Ensure the scheme and host match your configuration
    if (uri.scheme == 'yourapp' && uri.host == 'paymee') {
      String? paymentStatus = uri.queryParameters['payment_status'];
      String? paymentToken = uri
          .queryParameters['payment_token']; // Example: Extract token if needed

      // Use the navigatorKey to navigate
      if (paymentStatus == 'success') {
        navigatorKey.currentState?.pushNamed('/paymentSuccess');
      } else {
        navigatorKey.currentState?.pushNamed('/paymentError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey, // Assign the navigator key
      title: 'Sahel Alik',
      locale: localeProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // Use system theme by default
      home: const SplashScreen(), // Start with splash screen
      routes: {
        '/auth': (context) => const AuthWrapper(), // Route to auth wrapper
        '/providerHome': (context) => const ProviderHomeInterface(),
        '/searcherHome': (context) => const SearcherHomeInterface(),
        '/paymentSuccess': (context) =>
            const PaymentSuccessPage(), // Add success route
        '/paymentError': (context) =>
            const PaymentErrorPage(), // Add error route
        '/bookingScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final serviceId = args['serviceId'] as String;
          final providerId = args['providerId'] as String;
          return BookingScreen(serviceId: serviceId, providerId: providerId);
        },
        '/login': (context) => LoginInterface(showRegisterPage: () {}),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  const CircularProgressIndicator()); // Show loading indicator while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error case
        } else {
          final user = snapshot.data;
          if (user != null) {
            // User is logged in, navigate based on user type
            if (user.type == 'provider') {
              return const ProviderHomeInterface();
            } else {
              return const SearcherHomeInterface();
            }
          } else {
            // User is not logged in, show Login/Register
            return const LoginRegisterSwitcher();
          }
        }
      },
    );
  }
}

class LoginRegisterSwitcher extends StatefulWidget {
  const LoginRegisterSwitcher({super.key});

  @override
  LoginRegisterSwitcherState createState() => LoginRegisterSwitcherState();
}

class LoginRegisterSwitcherState extends State<LoginRegisterSwitcher> {
  bool _showLogin = true;

  void toggleView() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginInterface(showRegisterPage: toggleView);
    } else {
      return RegisterInterface(showLoginPage: toggleView);
    }
  }
}
