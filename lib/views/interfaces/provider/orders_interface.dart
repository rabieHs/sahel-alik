import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
                Text(
                    '${AppLocalizations.of(context)!.requestId}: ${request.bookingRequestId}'),
                Text(
                    '${AppLocalizations.of(context)!.serviceId}: ${request.serviceId}'),
                Text(
                    '${AppLocalizations.of(context)!.dateAndTime}: ${request.dateTime}'),
                Text(
                    '${AppLocalizations.of(context)!.description}: ${request.description}'),
                Text(
                    '${AppLocalizations.of(context)!.status}: ${request.status}'),
                const SizedBox(height: 10),
                if (request.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showPriceDialog(context, request);
                        },
                        child: Text(AppLocalizations.of(context)!.setPrice),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _rejectRequest(context, request);
                        },
                        child: Text(AppLocalizations.of(context)!.reject),
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
                Text(
                    '${AppLocalizations.of(context)!.requestId}: ${request.bookingRequestId}'),
                Text(
                    '${AppLocalizations.of(context)!.serviceId}: ${request.serviceId}'),
                Text(
                    '${AppLocalizations.of(context)!.dateAndTime}: ${request.dateTime}'),
                Text(
                    '${AppLocalizations.of(context)!.description}: ${request.description}'),
                Text(
                    '${AppLocalizations.of(context)!.userRating}: ${request.userRating ?? AppLocalizations.of(context)!.notRatedYet}'),
                Text(
                    '${AppLocalizations.of(context)!.status}: ${request.status}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _confirmPayment(context, request);
                  },
                  child: Text(AppLocalizations.of(context)!.confirmPayment),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _rejectRequest(
      BuildContext context, BookingRequestModel request) async {
    await _bookingRequestService.updateBookingRequestStatus(
        request.bookingRequestId!, 'rejected');
    _loadBookingRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.requestRejected)),
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
      SnackBar(
          content: Text(
              AppLocalizations.of(context)!.paymentConfirmedOrderFinished)),
    );
  }

  Future<void> _showPriceDialog(
      BuildContext context, BookingRequestModel request) async {
    final priceController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.setPriceForService),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterYourPrice),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.setPrice),
              onPressed: () {
                double? price = double.tryParse(priceController.text);
                if (price != null) {
                  _sendPriceRequest(context, request, price);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.invalidPrice)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPriceRequest(
      BuildContext context, BookingRequestModel request, double price) async {
    await _bookingRequestService.updateBookingRequestStatus(
      request.bookingRequestId!,
      'price_request',
      price: price,
    );
    debugPrint('Price sent for request ${request.bookingRequestId}: $price');
    _loadBookingRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.priceRequested)),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orders),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.pendingRequests),
            Tab(text: AppLocalizations.of(context)!.activeRequests),
            Tab(text: AppLocalizations.of(context)!.completedRequests),
            Tab(text: AppLocalizations.of(context)!.finishedRequests),
            Tab(text: AppLocalizations.of(context)!.paymentRequests),
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
