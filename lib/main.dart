import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sahel_alik/firebase_options.dart';
import 'package:sahel_alik/models/user.dart'; // Import UserModel
import 'package:sahel_alik/services/auth_service.dart';
import 'package:sahel_alik/views/interfaces/login_interface.dart';
import 'package:sahel_alik/views/interfaces/register_interface.dart';
import 'package:sahel_alik/views/interfaces/searcher/searcher_home_interface.dart';

import 'views/interfaces/provider/provider_home_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahel Alik',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.tealAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Use system theme by default
      home:
          const AuthWrapper(), // Use AuthWrapper to handle authentication state
      routes: {
        '/providerHome': (context) => const ProviderHomeInterface(),
        '/searcherHome': (context) => const SearcherHomeInterface(),
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
