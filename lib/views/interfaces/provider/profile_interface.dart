import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahel_alik/views/widgets/custom_button.dart';
import 'package:sahel_alik/services/auth_service.dart'; // Import AuthService
import 'package:sahel_alik/models/user.dart'; // Import UserModel

class ProfileInterface extends StatefulWidget {
  const ProfileInterface({super.key});

  @override
  State<ProfileInterface> createState() => _ProfileInterfaceState();
}

class _ProfileInterfaceState extends State<ProfileInterface> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    final user = await AuthService().getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_user?.profileImage ??
                        'https://via.placeholder.com/150'), // Use user profile image or placeholder
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      _user?.name ??
                          'User Name', // Display user name or default
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Update Name'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to update name page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Update Email'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to update email page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Update Password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to update password page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text('Sign Out',
                        style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // TODO: Navigate to login page
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
