import 'package:flutter/material.dart';
import 'package:sahel_alik/views/widgets/service_card.dart';
import 'package:sahel_alik/services/service_service.dart'; // Import ServiceService
import 'package:sahel_alik/models/service.dart'; // Import ServiceModel

class ServiceListInterface extends StatefulWidget {
  const ServiceListInterface({super.key});

  @override
  State<ServiceListInterface> createState() => _ServiceListInterfaceState();
}

class _ServiceListInterfaceState extends State<ServiceListInterface> {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = []; // Added filtered services list
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
    });
    final serviceService = ServiceService();
    List<ServiceModel> fetchedServices =
        await serviceService.getServicesForProvider('all');
    setState(() {
      _services = fetchedServices;
      _filteredServices = fetchedServices; // Initially show all services
    });
  }

  void _filterServices(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredServices = _services; // Show all services when query is empty
      });
    } else {
      setState(() {
        _filteredServices = _services
            .where((service) =>
                service.title!.toLowerCase().contains(query.toLowerCase()) ||
                service.description!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Services')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher Services',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterServices, // Call _filterServices on text change
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredServices.length, // Use _filteredServices
                itemBuilder: (context, index) {
                  return ServiceCard(
                    service: _filteredServices[index],
                    isProvider: true,
                    // Use _filteredServices
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
