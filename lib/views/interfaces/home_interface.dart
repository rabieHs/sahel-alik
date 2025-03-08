import 'package:flutter/material.dart';
import 'package:sahel_alik/views/widgets/custom_button.dart'; // Import CustomButton

import 'provider/profile_interface.dart'; // Import Profile Interface

class HomeInterface extends StatefulWidget {
  const HomeInterface({super.key});

  @override
  State<HomeInterface> createState() => _HomeInterfaceState();
}

class _HomeInterfaceState extends State<HomeInterface> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Map/Services Screen')), // Index 0
    Center(child: Text('Bookings Screen')), // Index 1
    ProfileInterface(), // Index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dar')),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Khidmat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Reservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // Optional: Set background color
        elevation: 4, // Optional: Add elevation for shadow
        type: BottomNavigationBarType.fixed, // Optional: Fixed or shifting
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        showUnselectedLabels:
            true, // Optional: Show labels for unselected items
      ),
    );
  }
}
