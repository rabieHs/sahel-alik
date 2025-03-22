import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../../services/service_service.dart';
import 'update_service_page.dart'; // Import for update service page
import '../../../models/service.dart';

class ServiceDetailsPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsPage({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            service.imageUrl != null
                ? Image.network(service.imageUrl!,
                    height: 200, width: double.infinity, fit: BoxFit.cover)
                : Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: double.infinity,
                  ),
            SizedBox(height: 16),
            Text('Title: ${service.title}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Description: ${service.description}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Price: \$${service.price}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: 'Update',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateServicePage(service: service),
                      ),
                    );
                  },
                ),
                CustomButton(
                  text: 'Delete',
                  onPressed: () async {
                    // Delete service logic
                    ServiceService serviceService =
                        ServiceService(); // Instantiate ServiceService
                    await serviceService.deleteService(service.id!);
                    Navigator.pop(context); // Go back to service list
                  },
                  backgroundColor: Colors.red, // Red color for delete button
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
