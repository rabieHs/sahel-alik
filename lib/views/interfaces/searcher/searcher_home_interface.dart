import 'package:flutter/material.dart';

import '../../widgets/service_card.dart'; // Import ServiceCard
import '../../../services/service_service.dart'; // Import ServiceService
import '../../../models/service.dart'; // Import ServiceModel

class SearcherHomeInterface extends StatefulWidget {
  const SearcherHomeInterface({super.key});

  @override
  State<SearcherHomeInterface> createState() => _SearcherHomeInterfaceState();
}

class _SearcherHomeInterfaceState extends State<SearcherHomeInterface> {
  int _selectedIndex = 0;
  final TextEditingController _searchController =
      TextEditingController(); // Search text controller
  List<ServiceModel> _services = []; // List to hold all services
  List<ServiceModel> _filteredServices = []; // List to hold filtered services

  @override
  void initState() {
    super.initState();
    _fetchServices(); // Fetch services when page loads
  }

  Future<void> _fetchServices() async {
    final serviceService = ServiceService();
    List<ServiceModel> services =
        await serviceService.getAllServices().first; // Fetch all services
    setState(() {
      _services = services;
      _filteredServices = services; // Initially show all services
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      // Initialized in build method
      Column(
        // Services Tab content
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search services',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Will implement search filtering logic here
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  10, // Placeholder item count, will update with actual service list
              itemBuilder: (context, index) {
                return Text('Service item $index'); // Placeholder service item
              },
            ),
          ),
        ],
      ),
      Text('Orders Tab'),
      Text('Profile Tab'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Searcher Home')),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
