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
  List<ServiceModel> _services = []; // Use ServiceModel instead of String
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
        await serviceService.getServicesForProvider();
    setState(() {
      _services = fetchedServices;
      _isLoading = false;
    });
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
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        return ServiceCard(
                          service: _services[index],
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
