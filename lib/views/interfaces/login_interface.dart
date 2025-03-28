import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../widgets/custom_button.dart';
import 'google_register_interface.dart'; // Import GoogleRegisterInterface

class LoginInterface extends StatefulWidget {
  static const routeName = '/login'; // Define routeName
  final VoidCallback showRegisterPage;
  const LoginInterface({Key? key, required this.showRegisterPage})
      : super(key: key);

  @override
  _LoginInterfaceState createState() => _LoginInterfaceState();
}

class _LoginInterfaceState extends State<LoginInterface> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Odkhol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            CustomButton(
              onPressed: () async {
                // Email/password login
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                if (email.isNotEmpty && password.isNotEmpty) {
                  AuthService authService = AuthService();
                  UserModel? user = await authService
                      .signInWithEmailAndPassword(email, password);
                  if (user != null) {
                    _navigateToHome(context, user);
                  } else {
                    _showSnackBar(context,
                        'Login failed. Please check your credentials.');
                  }
                } else {
                  _showSnackBar(context, 'Please enter email and password');
                }
              },
              text: 'Odkhol',
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () async {
                // Google Sign-in
                AuthService authService = AuthService();
                UserModel? user = await authService.signInWithGoogle();
                if (user != null) {
                  _navigateToHomeOrCompleteRegistration(context, user);
                } else {
                  _showSnackBar(
                      context, 'Google Sign-In failed. Please try again.');
                }
              },
              text: 'Sign in with Google',
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/searcherHome');
              },
              child: const Text(
                'Skip for now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Ma andekech compte?"),
                TextButton(
                  onPressed: () {
                    widget.showRegisterPage();
                  },
                  child: const Text(
                    'A3mel Compte',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHomeOrCompleteRegistration(
      BuildContext context, UserModel user) {
    if (user.type == 'provider') {
      Navigator.pushReplacementNamed(context, '/providerHome');
    } else if (user.type == 'searcher') {
      Navigator.pushReplacementNamed(context, '/searcherHome');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GoogleRegisterInterface(
            showLoginPage: widget.showRegisterPage,
            googleEmail: user.email ?? '', // Pass google email
          ),
        ),
      );
    }
  }

  void _navigateToHome(BuildContext context, UserModel user) {
    if (user.type == 'provider') {
      Navigator.pushReplacementNamed(context, '/providerHome');
    } else {
      Navigator.pushReplacementNamed(context, '/searcherHome');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
