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
      appBar: AppBar(title: const Text('Odkhol (Login)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Gmail',
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
                labelText: 'Mot de passe',
                hintText: 'Mot de passe',
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
                    _showSnackBar(
                        context, 'Login meklech. Thabet fi m3aloumet.');
                  }
                } else {
                  _showSnackBar(context, 'Adkhel email w mot de passe.');
                }
              },
              text: 'Odkhol (Login)',
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
                      context, 'Odkhol b Google meklech. Aawed jarr.');
                }
              },
              text: 'Odkhol b Google (Login)',
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/searcherHome');
              },
              child: const Text(
                'Nfout dima (Skip)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Ma andekech compte ? (No account?)"),
                TextButton(
                  onPressed: () {
                    widget.showRegisterPage();
                  },
                  child: const Text(
                    'A3mel Compte (Register)',
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
