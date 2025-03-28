import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_button.dart';
import '../../../models/service.dart';
import '../../../models/user.dart';
import '../login_interface.dart';
import 'booking_screen.dart'; // Import BookingScreen
import '../../../services/auth_service.dart';

class ServiceDetailsPage extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailsPage({Key? key, required this.service}) : super(key: key);

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  UserModel? _providerDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviderDetails();
  }

  Future<void> _fetchProviderDetails() async {
    try {
      final authService = AuthService();
      // Fetch user details based on the service's userId
      if (widget.service.userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.service.userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _providerDetails = UserModel.fromJson(userDoc.data() ?? {});
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching provider details: $e');
    }
  }

  String _formatLocation(GeoPoint? location) {
    if (location == null) return 'N/A';
    return '${location.latitude}, ${location.longitude}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = widget.service;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                service.title ?? 'Service Details',
                style:
                    theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              background: service.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: service.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported,
                            color: theme.primaryColor),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported,
                          color: theme.primaryColor),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Service Details Section
                _buildSectionTitle('Service Information', Icons.info_outline),
                _buildInfoCard(
                  context,
                  children: [
                    _buildDetailRow('Category', service.category ?? 'N/A'),
                    _buildDetailRow(
                        'Description', service.description ?? 'N/A'),
                    _buildDetailRow(
                        'Location', _formatLocation(service.location)),
                    _buildDetailRow(
                        'Price',
                        service.price != null
                            ? '\$${service.price!.toStringAsFixed(2)}'
                            : 'N/A'),
                  ],
                ),

                // Provider Information Section
                _buildSectionTitle('Provider Details', Icons.person_outline),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      )
                    : _buildProviderInfoCard(context),

                // Booking Section
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Book Now',
                  onPressed: () async {
                    final authService = AuthService();
                    final user = await authService.getCurrentUser();
                    if (user != null) {
                      Navigator.pushNamed(
                        context,
                        BookingScreen
                            .routeName, // Navigate to booking screen if logged in
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        LoginInterface
                            .routeName, // Navigate to login screen if not logged in
                      );
                    }
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
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
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfoCard(BuildContext context) {
    final providerDetails = _providerDetails;
    return providerDetails != null
        ? _buildInfoCard(
            context,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: providerDetails.profileImage != null
                      ? NetworkImage(providerDetails.profileImage!)
                      : null,
                  child: providerDetails.profileImage == null
                      ? Icon(Icons.person,
                          size: 50, color: Theme.of(context).primaryColor)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', providerDetails.name ?? 'N/A'),
              _buildDetailRow('Email', providerDetails.email ?? 'N/A'),
              _buildDetailRow('Phone', providerDetails.phone ?? 'N/A'),
            ],
          )
        : Center(
            child: Text(
              'Provider details not available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          );
  }
}
