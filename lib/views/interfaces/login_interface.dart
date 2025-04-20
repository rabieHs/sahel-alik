import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../utils/validation_utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/language_switcher.dart';
import 'google_register_interface.dart'; // Import GoogleRegisterInterface

class LoginInterface extends StatefulWidget {
  static const routeName = '/login'; // Define routeName
  final VoidCallback showRegisterPage;
  const LoginInterface({super.key, required this.showRegisterPage});

  @override
  State<LoginInterface> createState() => _LoginInterfaceState();
}

class _LoginInterfaceState extends State<LoginInterface> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.login),
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
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
              const SizedBox(height: 30),
              CustomButton(
                onPressed: _isLoading
                    ? () {}
                    : () {
                        _handleLogin();
                      },
                text: AppLocalizations.of(context)!.login,
                loading: _isLoading,
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: _isLoading
                    ? () {}
                    : () {
                        _handleGoogleLogin();
                      },
                text: AppLocalizations.of(context)!.loginWithGoogle,
                loading: _isLoading,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/searcherHome');
                },
                child: Text(
                  AppLocalizations.of(context)!.skip,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.noAccount),
                  TextButton(
                    onPressed: () {
                      widget.showRegisterPage();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.register,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Email/password login
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      AuthService authService = AuthService();
      UserModel? user =
          await authService.signInWithEmailAndPassword(email, password);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        _navigateToHome(user);
      } else {
        _showSnackBar(AppLocalizations.of(context)!.loginFailed);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // Google Sign-in
    AuthService authService = AuthService();
    UserModel? user = await authService.signInWithGoogle();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      _navigateToHomeOrCompleteRegistration(user);
    } else {
      _showSnackBar(AppLocalizations.of(context)!.googleLoginFailed);
    }
  }

  void _navigateToHomeOrCompleteRegistration(UserModel user) {
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

  void _navigateToHome(UserModel user) {
    if (user.type == 'provider') {
      Navigator.pushReplacementNamed(context, '/providerHome');
    } else {
      Navigator.pushReplacementNamed(context, '/searcherHome');
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
