import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Import AuthService
import '../../models/user.dart'; // Import UserModel
import '../widgets/custom_button.dart'; // Import CustomButton

class GoogleRegisterInterface extends StatefulWidget {
  final VoidCallback showLoginPage;
  final String googleEmail;
  const GoogleRegisterInterface(
      {super.key, required this.showLoginPage, required this.googleEmail});

  @override
  State<GoogleRegisterInterface> createState() =>
      _GoogleRegisterInterfaceState();
}

class _GoogleRegisterInterfaceState extends State<GoogleRegisterInterface> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isServiceProvider = false;

  @override
  void initState() {
    super.initState();
    _emailController.text =
        widget.googleEmail; // Pre-fill email from Google Sign-In
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Esmek',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Disable editing email
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('3andek service'),
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
                // Implement Google Register functionality
                String name = _nameController.text;
                String email = _emailController.text;
                String phone = _phoneController.text;

                if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
                  AuthService authService = AuthService();
                  UserModel? user = await authService.registerWithGoogle(
                      name, email, phone, _isServiceProvider);
                  if (user != null) {
                    if (user.type == 'provider') {
                      Navigator.pushReplacementNamed(context, '/providerHome');
                    } else {
                      Navigator.pushReplacementNamed(context, '/searcherHome');
                    }
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration failed. Please try again.'),
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
              text: 'Complete Registration',
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
