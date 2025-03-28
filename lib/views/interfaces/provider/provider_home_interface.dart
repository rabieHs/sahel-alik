import 'package:flutter/material.dart';
import 'package:sahel_alik/views/widgets/custom_button.dart';
import '../profile_interface.dart';
import 'add_service_interface.dart';
import 'orders_interface.dart';
import 'service_list_interface.dart';

class ProviderHomeInterface extends StatefulWidget {
  const ProviderHomeInterface({super.key});

  @override
  State<ProviderHomeInterface> createState() => _ProviderHomeInterfaceState();
}

class _ProviderHomeInterfaceState extends State<ProviderHomeInterface> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = [
    ServiceListInterface(),
    ProviderOrdersInterface(),
    const ProfileInterface(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Home')),
      body: Stack(
        children: [
          Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          if (_selectedIndex == 0) // Show FAB only on Services screen
            Positioned(
              bottom: 20,
              right: 20,
              child: CustomButton(
                // Use CustomButton for FloatingActionButton
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddServiceInterface()),
                  );
                },
                text:
                    'Add Service', // You can change the text if needed, or use an icon
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        showUnselectedLabels: true,
      ),
    );
  }
}
