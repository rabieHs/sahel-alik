import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Import AuthService
import '../../models/user.dart'; // Import UserModel
import '../widgets/custom_button.dart'; // Import CustomButton

class LoginInterface extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginInterface({super.key, required this.showRegisterPage});

  @override
  State<LoginInterface> createState() => _LoginInterfaceState();
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
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(
                  // Use const here
                  borderRadius: BorderRadius.all(
                      Radius.circular(12)), // More explicit BorderRadius
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(
                  // Use const here
                  borderRadius: BorderRadius.all(
                      Radius.circular(12)), // More explicit BorderRadius
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            CustomButton(
              onPressed: () async {
                // Implement Login functionality
                String email = _emailController.text;
                String password = _passwordController.text;

                if (email.isNotEmpty && password.isNotEmpty) {
                  AuthService authService = AuthService();
                  UserModel? user = await authService
                      .signInWithEmailAndPassword(email, password);
                  if (user != null) {
                    // Navigate to home page based on user type
                    if (user.type == 'provider') {
                      Navigator.pushReplacementNamed(context, '/providerHome');
                    } else {
                      Navigator.pushReplacementNamed(context, '/searcherHome');
                    }
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login failed. Please try again.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields.'),
                    ),
                  );
                }
              },
              text: 'Odkhol',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Ma andekech compte?"),
                TextButton(
                  child: const Text(
                    'A3mel Compte',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    widget.showRegisterPage();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
