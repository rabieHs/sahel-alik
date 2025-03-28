import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Failed to load user information.'))
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
                      _buildInfoRow('Name', _user?.name ?? 'N/A'),
                      _buildInfoRow('Email', _user?.email ?? 'N/A'),
                      _buildInfoRow('Phone', _user?.phone ?? 'N/A'),
                      _buildInfoRow('Type', _user?.type ?? 'N/A'),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await AuthService().signOut();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Sign Out'),
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
}
