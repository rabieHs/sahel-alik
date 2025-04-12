import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Import AuthService
import '../../models/user.dart'; // Import UserModel
import '../widgets/custom_button.dart'; // Import CustomButton

class RegisterInterface extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterInterface({super.key, required this.showLoginPage});

  @override
  State<RegisterInterface> createState() => _RegisterInterfaceState();
}

class _RegisterInterfaceState extends State<RegisterInterface> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isServiceProvider = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A3mel Compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Esmek',
                hintText: 'Esmek',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Gmail',
                hintText: 'Gmail',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: 'Mot de passe',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Num tel',
                hintText: 'Num tel',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('3andek service ?'),
                Switch(
                  value: _isServiceProvider,
                  onChanged: (value) {
                    setState(() {
                      _isServiceProvider = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomButton(
              onPressed: () async {
                // Implement Register functionality
                String name = _nameController.text;
                String email = _emailController.text;
                String password = _passwordController.text;
                String phone = _phoneController.text;

                if (name.isNotEmpty &&
                    email.isNotEmpty &&
                    password.isNotEmpty &&
                    phone.isNotEmpty) {
                  AuthService authService = AuthService();
                  UserModel? user =
                      await authService.registerWithEmailAndPassword(
                          name, email, password, phone, _isServiceProvider);
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
                        content: Text('Tasjil meklech. Aawed jarr.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aabbi kol chay svp.'),
                    ),
                  );
                }
              },
              text: 'A3mel Compte',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("3andi compte?"),
                TextButton(
                  child: const Text(
                    'Odkhol',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    widget.showLoginPage();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
