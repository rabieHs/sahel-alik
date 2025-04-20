import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/custom_button.dart';
import '../../../services/service_service.dart';
import 'update_service_page.dart'; // Import for update service page
import '../../../models/service.dart';
import '../../../services/auth_service.dart'; // Import AuthService
import '../../../models/user.dart'; // Import UserModel
// Removed unused import

class ProviderServiceDetailsPage extends StatefulWidget {
  final ServiceModel service;

  const ProviderServiceDetailsPage({super.key, required this.service});

  @override
  State<ProviderServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ProviderServiceDetailsPage> {
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
      // Service has no provider ID
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.serviceDetails),
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
                      Text(AppLocalizations.of(context)!.providerInformation,
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
                    Text(AppLocalizations.of(context)!.serviceDetails,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    _buildDetailRow(AppLocalizations.of(context)!.titleLabel,
                        widget.service.title ?? 'N/A'),
                    _buildDetailRow(AppLocalizations.of(context)!.description,
                        widget.service.description ?? 'N/A'),
                    _buildDetailRow(
                        AppLocalizations.of(context)!.price,
                        AppLocalizations.of(context)!
                            .pricePerHour(widget.service.price ?? 0)),
                    if (widget.service.location != null)
                      _buildDetailRow(AppLocalizations.of(context)!.location,
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
                  text: AppLocalizations.of(context)!.updateButton,
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
                  text: AppLocalizations.of(context)!.deleteButton,
                  onPressed: () async {
                    // Delete service logic
                    ServiceService serviceService =
                        ServiceService(); // Instantiate ServiceService
                    await serviceService.deleteService(
                        widget.service.id!); // Use widget.service
                    if (!mounted) return;
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
