import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/auth_service.dart'; // Import AuthService
import '../../models/user.dart'; // Import UserModel
import '../../utils/validation_utils.dart';
import '../widgets/custom_button.dart'; // Import CustomButton
import '../widgets/language_switcher.dart';

class RegisterInterface extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterInterface({super.key, required this.showLoginPage});

  @override
  State<RegisterInterface> createState() => _RegisterInterfaceState();
}

class _RegisterInterfaceState extends State<RegisterInterface> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isServiceProvider = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.register),
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name,
                  hintText: AppLocalizations.of(context)!.name,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) =>
                    ValidationUtils.validateName(value, context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  hintText: AppLocalizations.of(context)!.email,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    ValidationUtils.validateEmail(value, context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  hintText: AppLocalizations.of(context)!.password,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                obscureText: true,
                validator: (value) =>
                    ValidationUtils.validatePassword(value, context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  hintText: AppLocalizations.of(context)!.phoneNumber,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    ValidationUtils.validatePhone(value, context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.areYouProvider),
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
                onPressed: _isLoading
                    ? () {}
                    : () {
                        _handleRegister();
                      },
                text: AppLocalizations.of(context)!.register,
                loading: _isLoading,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.haveAccount),
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.login,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Implement Register functionality
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String phone = _phoneController.text;

      AuthService authService = AuthService();
      UserModel? user = await authService.registerWithEmailAndPassword(
          name, email, password, phone, _isServiceProvider);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        // Navigate to home page based on user type
        if (user.type == 'provider') {
          Navigator.pushReplacementNamed(context, '/providerHome');
        } else {
          Navigator.pushReplacementNamed(context, '/searcherHome');
        }
      } else {
        // Show error message
        _showSnackBar(AppLocalizations.of(context)!.registrationFailed);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
