import 'package:flutter/material.dart';
import 'package:sahel_alik/views/interfaces/searcher/searcher_orders_tab.dart';
import 'package:sahel_alik/views/interfaces/searcher/searcher_services_tab.dart';

import '../../widgets/service_card.dart';
import '../../../services/service_service.dart';
import '../../../models/service.dart';
import '../profile_interface.dart';
import '../../../utils/location_utils.dart';

class SearcherHomeInterface extends StatefulWidget {
  const SearcherHomeInterface({super.key});

  @override
  State<SearcherHomeInterface> createState() => _SearcherHomeInterfaceState();
}

class _SearcherHomeInterfaceState extends State<SearcherHomeInterface> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  bool _isLoading = true;
  double _radius = 5.0; // Default radius

  List<Map<String, dynamic>> categories = [
    {'name': 'Maid', 'icon': Icons.home_work},
    {'name': 'Cleaner', 'icon': Icons.cleaning_services},
    {'name': 'Mechanic', 'icon': Icons.build},
    {'name': 'Barber', 'icon': Icons.content_cut},
    {'name': 'Plumber', 'icon': Icons.plumbing},
    {'name': 'Electrician', 'icon': Icons.electrical_services},
    {'name': 'Carpenter', 'icon': Icons.carpenter},
    {'name': 'Painter', 'icon': Icons.format_paint},
    {'name': 'Gardener', 'icon': Icons.nature},
    {'name': 'Chef', 'icon': Icons.restaurant},
    {'name': 'Tutor', 'icon': Icons.school},
    {'name': 'Driver', 'icon': Icons.drive_eta},
    {'name': 'More', 'icon': Icons.category},
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices({double? radius}) async {
    setState(() {
      _isLoading = true;
    });
    final serviceService = ServiceService();
    final position = await LocationUtils.getCurrentPosition();
    double searchRadius = radius ?? _radius; // Use provided radius or default

    if (position != null) {
      final servicesStream = serviceService.getNearestServices(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: searchRadius,
      );
      servicesStream.first.then((services) {
        setState(() {
          _services = services;
          _filteredServices = services;
          _isLoading = false;
        });
      });
    } else {
      final allServicesStream = serviceService.getAllServices();
      allServicesStream.first.then((services) {
        setState(() {
          _services = services;
          _filteredServices = services;
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location not available, showing all services.')),
          );
        });
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      // Services Tab - Modified to include Categories and Service List
      SearcherServicesTab(),
      SearcherOrdersTab(),
      const ProfileInterface(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Searcher Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
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

  void _filterServices(String query) {
    String lowerCaseQuery = query.toLowerCase();
    List<ServiceModel> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = _services
          .where((service) =>
              service.title!.toLowerCase().contains(lowerCaseQuery) ||
              service.description!.toLowerCase().contains(lowerCaseQuery))
          .toList();
    } else {
      filteredList = List.from(_services);
    }
    setState(() {
      _filteredServices = filteredList;
    });
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    double tempRadius = _radius; // Temporary radius value for the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Radius'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Select radius (km):'),
                  Slider(
                    value: tempRadius,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    label: tempRadius.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        tempRadius = value;
                      });
                    },
                  ),
                  Text('${tempRadius.toStringAsFixed(1)} km'),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                setState(() {
                  _radius = tempRadius; // Update radius with temp value
                });
                _fetchServices(
                    radius: _radius); // Re-fetch services with radius
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
