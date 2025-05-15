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
  bool _obscurePassword = true; // For password visibility toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // App Logo and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.handshake_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sahel Alik',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.login,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        ValidationUtils.validateEmail(value, context),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) =>
                        ValidationUtils.validatePassword(value, context),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Implement forgot password functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Forgot password functionality coming soon')),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.forgotPassword),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.login),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Or divider
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.or,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Login Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.g_mobiledata,
                            size: 28,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.loginWithGoogle),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Skip Button
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/searcherHome');
                    },
                    child: Text(AppLocalizations.of(context)!.skip),
                  ),
                  const SizedBox(height: 20),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.noAccount),
                      TextButton(
                        onPressed: widget.showRegisterPage,
                        child: Text(
                          AppLocalizations.of(context)!.register,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Language Switcher
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: LanguageSwitcher(),
                    ),
                  ),
                ],
              ),
            ),
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
