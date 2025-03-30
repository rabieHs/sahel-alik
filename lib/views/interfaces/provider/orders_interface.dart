import 'package:flutter/material.dart';
import '../../../services/auth_service.dart'; // Import AuthService
import '../../widgets/service_card.dart';
import '../../../services/service_service.dart';
import '../../../services/booking_request_service.dart';
import '../../../models/service.dart';
import '../../../models/booking_request.dart';

class ProviderOrdersInterface extends StatefulWidget {
  const ProviderOrdersInterface({super.key});

  @override
  ProviderOrdersInterfaceState createState() => ProviderOrdersInterfaceState();
}

class ProviderOrdersInterfaceState extends State<ProviderOrdersInterface>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ServiceService _serviceService = ServiceService();
  final BookingRequestService _bookingRequestService = BookingRequestService();
  List<BookingRequestModel> pendingRequests = [];
  List<BookingRequestModel> activeRequests = [];
  List<BookingRequestModel> completedRequests = [];
  List<BookingRequestModel> finishedRequests = [];
  List<BookingRequestModel> paymentRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadBookingRequests(); // Changed function name to reflect booking requests
  }

  final AuthService authService =
      AuthService(); // Create an instance of AuthService

  Future<void> _loadBookingRequests() async {
    final user = await authService.getCurrentUser();
    if (user != null) {
      pendingRequests =
          await _bookingRequestService.getBookingRequestsForProvider(
              user.uid!, 'pending'); // Pass providerId, using null assertion
      activeRequests =
          await _bookingRequestService.getBookingRequestsForProvider(
              user.uid!, 'active'); // Pass providerId, using null assertion
      completedRequests =
          await _bookingRequestService.getBookingRequestsForProvider(
              user.uid!, 'completed'); // Pass providerId, using null assertion
      finishedRequests =
          await _bookingRequestService.getBookingRequestsForProvider(
              user.uid!, 'finished'); // Pass providerId, using null assertion
      paymentRequests = await _bookingRequestService.getBookingRequestsForProvider(
          user.uid!,
          'payment_request'); // Corrected status and pass providerId, using null assertion
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildRequestsTab(String status) {
    // Changed to RequestsTab
    List<BookingRequestModel> requests = [];
    if (status == 'pending') {
      requests = pendingRequests;
    } else if (status == 'active') {
      requests = activeRequests;
    } else if (status == 'completed') {
      requests = completedRequests;
    } else if (status == 'finished') {
      requests = finishedRequests;
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request ID: ${request.bookingRequestId}'),
                Text('Service ID: ${request.serviceId}'),
                Text('Date/Time: ${request.dateTime}'),
                Text('Description: ${request.description}'),
                Text('Status: ${request.status}'),
                const SizedBox(height: 10),
                if (request.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _acceptRequest(context, request);
                        },
                        child: const Text('Accept'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _rejectRequest(context, request);
                        },
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentRequestsTab() {
    return ListView.builder(
      itemCount: paymentRequests.length,
      itemBuilder: (context, index) {
        final request = paymentRequests[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request ID: ${request.bookingRequestId}'),
                Text('Service ID: ${request.serviceId}'),
                Text('Date/Time: ${request.dateTime}'),
                Text('Description: ${request.description}'),
                Text('User Rating: ${request.userRating ?? 'Not rated yet'}'),
                Text('Status: ${request.status}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _confirmPayment(context, request);
                  },
                  child: const Text('Confirm Payment'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _acceptRequest(
      BuildContext context, BookingRequestModel request) async {
    await _bookingRequestService.updateBookingRequestStatus(
        request.bookingRequestId!, 'active');
    _loadBookingRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request Accepted')),
    );
  }

  Future<void> _rejectRequest(
      BuildContext context, BookingRequestModel request) async {
    await _bookingRequestService.updateBookingRequestStatus(
        request.bookingRequestId!, 'rejected');
    _loadBookingRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request Rejected')),
    );
  }

  Future<void> _confirmPayment(
      BuildContext context, BookingRequestModel request) async {
    await _bookingRequestService.updateBookingRequestStatus(
      request.bookingRequestId!,
      'finished',
      userRating: request.userRating,
    );
    _loadBookingRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Confirmed and Order Finished')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending Requests'), // Changed to Requests
            Tab(text: 'Active Requests'), // Changed to Requests
            Tab(text: 'Completed Requests'), // Changed to Requests
            Tab(text: 'Finished Requests'), // Changed to Requests
            Tab(text: 'Payment Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab('pending'), // Changed to RequestsTab
          _buildRequestsTab('active'), // Changed to RequestsTab
          _buildRequestsTab('completed'), // Changed to RequestsTab
          _buildRequestsTab('finished'), // Changed to RequestsTab
          _buildPaymentRequestsTab(),
        ],
      ),
    );
  }
}
