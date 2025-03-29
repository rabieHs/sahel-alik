import 'package:flutter/material.dart';

import '../../widgets/service_card.dart';
import '../../../services/service_service.dart';
import '../../../models/service.dart';
import '../../../utils/location_utils.dart';

class SearcherServicesTab extends StatefulWidget {
  const SearcherServicesTab({super.key});

  @override
  State<SearcherServicesTab> createState() => _SearcherServicesTabState();
}

class _SearcherServicesTabState extends State<SearcherServicesTab> {
  String? _selectedCategory;
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  bool _isLoading = true;
  double _radius = 5.0; // Default radius
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            // Categories Horizontal Listview
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return FilterChip(
                    avatar: Icon(category['icon'] as IconData),
                    label: Text(category['name'] as String),
                    selected: _selectedCategory == category['name'],
                    onSelected: (bool selected) async {
                      setState(() {
                        _selectedCategory =
                            selected ? category['name'] as String : null;
                        _isLoading = true;
                      });

                      if (selected) {
                        final position =
                            await LocationUtils.getCurrentPosition();
                        if (position != null) {
                          final services = await ServiceService()
                              .getServicesByCategoryAndLocation(
                                category: category['name'],
                                latitude: position.latitude,
                                longitude: position.longitude,
                                radius: 5.0,
                              )
                              .first;
                          setState(() {
                            _filteredServices = services;
                            _isLoading = false;
                          });
                        } else {
                          setState(() {
                            _isLoading = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Location not available.')),
                            );
                          });
                        }
                      } else {
                        _fetchServices();
                      }
                    },
                  );
                },
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search services',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    _filterServices, // Call _filterServices on text change
              ),
            ),
            // Filtered Services List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // Loading indicator
                  : ListView.builder(
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];
                        return ServiceCard(service: service);
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
