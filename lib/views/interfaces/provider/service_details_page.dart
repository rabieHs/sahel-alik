import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../../services/service_service.dart';
import 'update_service_page.dart'; // Import for update service page
import '../../../models/service.dart';
import '../../../services/auth_service.dart'; // Import AuthService
import '../../../models/user.dart'; // Import UserModel
import '../../interfaces/searcher/booking_screen.dart'; // Corrected import path for BookingScreen

class ServiceDetailsPage extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailsPage({Key? key, required this.service}) : super(key: key);

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  UserModel? provider;

  @override
  void initState() {
    super.initState();
    _fetchProvider();
  }

  _fetchProvider() async {
    AuthService authService = AuthService();
    final userId = widget.service.userId;
    if (userId != null) {
      UserModel? fetchedProvider = await authService.getUserById(userId);
      setState(() {
        provider = fetchedProvider;
      });
    } else {
      // Handle the case where userId is null, e.g., set provider to null or show an error message
      print("Service has no provider ID.");
    }
  }

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
            widget.service.imageUrl != null // Use widget.service
                ? Image.network(widget.service.imageUrl!, // Use widget.service
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover)
                : Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: double.infinity,
                  ),
            SizedBox(height: 16),
            if (provider != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Provider Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ListTile(
                        leading: provider!.profileImage != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(provider!.profileImage!),
                              )
                            : CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(provider!.name ?? 'N/A'),
                        subtitle: Text(provider!.email ?? 'N/A'),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    _buildDetailRow('Title', widget.service.title ?? 'N/A'),
                    _buildDetailRow(
                        'Description', widget.service.description ?? 'N/A'),
                    _buildDetailRow(
                        'Price', '\$${widget.service.price ?? 'N/A'}'),
                    if (widget.service.location != null)
                      _buildDetailRow('Location',
                          'Lat: ${widget.service.location!.latitude.toStringAsFixed(2)}, Lon: ${widget.service.location!.longitude.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
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
                        builder: (context) => UpdateServicePage(
                            service: widget.service), // Use widget.service
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
                    await serviceService.deleteService(
                        widget.service.id!); // Use widget.service
                    Navigator.pop(context); // Go back to service list
                  },
                  backgroundColor: Colors.red, // Red color for delete button
                ),
              ],
            ),
            SizedBox(height: 32),
            CustomButton(
              text: 'Book Service',
              onPressed: () async {
                AuthService authService = AuthService();
                UserModel? currentUser = await authService.getCurrentUser();
                if (currentUser != null) {
                  // User is logged in, navigate to booking page
                  Navigator.pushNamed(
                    context,
                    BookingScreen.routeName,
                    arguments: {'service': widget.service},
                  );
                } else {
                  // User is not logged in, navigate to login page
                  Navigator.pushNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
