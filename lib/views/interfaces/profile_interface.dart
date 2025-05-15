import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class ProfileInterface extends StatefulWidget {
  const ProfileInterface({Key? key}) : super(key: key);

  @override
  _ProfileInterfaceState createState() => _ProfileInterfaceState();
}

class _ProfileInterfaceState extends State<ProfileInterface> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  _loadCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    UserModel? user = await AuthService().getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle case where user is not logged in or error fetching user
      print("Could not load current user");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child:
                      Text(AppLocalizations.of(context)!.userProfileNotFound))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Header with Background
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Image
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: _user?.profileImage != null &&
                                        _user!.profileImage!.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 48,
                                        backgroundImage:
                                            NetworkImage(_user!.profileImage!),
                                      )
                                    : CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: Text(
                                          _user?.name?.isNotEmpty == true
                                              ? _user!.name![0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              // User Name
                              Text(
                                _user?.name ??
                                    AppLocalizations.of(context)!.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              // User Type Badge
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withAlpha(51), // 0.2 opacity
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _user?.type?.toUpperCase() ?? 'USER',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Profile Information Cards
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Personal Information Card
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .personalInformation,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const Divider(),
                                    _buildProfileInfoItem(
                                      context,
                                      Icons.email_outlined,
                                      AppLocalizations.of(context)!.email,
                                      _user?.email ?? 'N/A',
                                    ),
                                    _buildProfileInfoItem(
                                      context,
                                      Icons.phone_outlined,
                                      AppLocalizations.of(context)!.phoneNumber,
                                      _user?.phone ?? 'N/A',
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Account Information Card
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .accountInformation,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const Divider(),
                                    _buildProfileInfoItem(
                                      context,
                                      Icons.account_balance_wallet_outlined,
                                      AppLocalizations.of(context)!
                                          .balanceLabel,
                                      "${_user?.balance} دينار",
                                    ),
                                    _buildProfileInfoItem(
                                      context,
                                      Icons.person_outline,
                                      AppLocalizations.of(context)!.accountType,
                                      _user?.type?.toUpperCase() ?? 'N/A',
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Settings & Actions
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.settings_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    title: Text(
                                        AppLocalizations.of(context)!.settings),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      // Navigate to settings
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .settingsComingSoon)),
                                      );
                                    },
                                  ),
                                  const Divider(height: 1),
                                  ListTile(
                                    leading: Icon(Icons.help_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    title: Text(AppLocalizations.of(context)!
                                        .helpAndSupport),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      // Navigate to help
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .helpAndSupportComingSoon)),
                                      );
                                    },
                                  ),
                                  const Divider(height: 1),
                                  ListTile(
                                    leading:
                                        Icon(Icons.logout, color: Colors.red),
                                    title: Text(
                                        AppLocalizations.of(context)!.signOut),
                                    onTap: _signOut,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}
