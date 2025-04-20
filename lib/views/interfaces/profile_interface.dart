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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profile)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child:
                      Text(AppLocalizations.of(context)!.userProfileNotFound))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(_user?.profileImage ?? ''),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(AppLocalizations.of(context)!.name,
                          _user?.name ?? 'N/A'),
                      _buildInfoRow(AppLocalizations.of(context)!.email,
                          _user?.email ?? 'N/A'),
                      _buildInfoRow(AppLocalizations.of(context)!.phoneNumber,
                          _user?.phone ?? 'N/A'),
                      _buildInfoRow('Type', _user?.type ?? 'N/A'),
                      _buildInfoRow('Balance', "${_user?.balance} دينار"),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _signOut();
                          },
                          child: Text(AppLocalizations.of(context)!.signOut),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
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
