import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // Import http; // Import http
import 'dart:convert'; // Import convert
import '../../../services/auth_service.dart';
import '../../../models/booking_request.dart';
import '../../../models/service.dart'; // Import ServiceModel
import '../../widgets/custom_button.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'payment_webview_page.dart';
import 'payment_success_page.dart';
import 'payment_error_page.dart';

class SearcherOrdersTab extends StatefulWidget {
  const SearcherOrdersTab({Key? key}) : super(key: key);

  @override
  _SearcherOrdersTabState createState() => _SearcherOrdersTabState();
}

class _SearcherOrdersTabState extends State<SearcherOrdersTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double _rating = 3.0; // Default rating value

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 5, vsync: this); // Increased tab length to 5
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true, // Added isScrollable
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
          Tab(text: 'Finished'), // Added Finished tab
          Tab(text: 'All'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab('pending'),
          _buildOrdersTab('active'),
          _buildOrdersTab('completed'),
          _buildOrdersTab('finished'), // Added Finished tab
          _buildOrdersTab('all'),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(String status) {
    return FutureBuilder<List<BookingRequestModel>>(
      future: _fetchBookingRequests(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final request = orders[index];
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
                    Text(
                        'User Rating: ${request.paymentMethod == 'cash' && request.status == 'finished' ? 'You rated this service ${request.userRating ?? _rating} stars' : 'Not rated yet'}'), // Display user rating
                    Text('Status: ${request.status}'),
                    const SizedBox(height: 10),
                    // Conditionally render buttons based on status
                    if (request.status == 'completed')
                      CustomButton(
                        text: 'Pay',
                        onPressed: () {
                          _showPaymentDialog(context, request);
                        },
                      ),
                    if (request.status == 'active')
                      CustomButton(
                        text: 'Complete Order',
                        onPressed: () {
                          _completeOrder(context, request);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<BookingRequestModel>> _fetchBookingRequests(String status) async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    if (user != null) {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('booking_requests')
          .where('userId', isEqualTo: user.uid);

      if (status != 'all') {
        query = query.where('status', isEqualTo: status);
      }
      // Removed redundant check for status == 'finished' as it's covered above

      final bookingRequestsSnapshot = await query.get();
      return bookingRequestsSnapshot.docs
          .map((doc) => BookingRequestModel.fromJson(doc.data()))
          .toList();
    } else {
      return [];
    }
  }

  void _showPaymentDialog(BuildContext context, BookingRequestModel request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Pay with Cash'),
                onTap: () {
                  Navigator.pop(context);
                  _payWithCash(context, request);
                },
              ),
              ListTile(
                title: const Text('Pay Online'),
                onTap: () {
                  _payOnline(context, request);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _payWithCash(BuildContext context, BookingRequestModel request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pay with Cash'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Please rate the service you received:'),
              const SizedBox(height: 20),
              RatingBar.builder(
                // Use flutter_rating_bar
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Confirm Payment',
                onPressed: () {
                  Navigator.pop(context);
                  _paymentRequested(context, request, _rating);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _paymentRequested(
      BuildContext context, BookingRequestModel request, double rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(request.bookingRequestId)
          .update({
        'status': 'payment_request',
        'paymentMethod': 'cash',
        'userRating': rating,
      });
      debugPrint(
          'Booking request ${request.bookingRequestId} status updated to payment_request');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Payment requested. Status updated to payment_request.')),
      );
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting payment: $error')),
      );
    }
  }

  void _payOnline(BuildContext context, BookingRequestModel request) async {
    final String apiKey =
        'f10ee1ca2c45f81aaf92a8ea05e0d681e269bfbb'; // Replace with your actual API key
    final String createPaymentUrl =
        'https://sandbox.paymee.tn/api/v2/payments/create';
    final authService = AuthService();
    final user = await authService.getCurrentUser();

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    // Fetch user profile from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || userDoc.data() == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not found.')),
      );
      return;
    }

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    debugPrint('User data: $userData'); // Log user data

    // Fetch service details to get the price
    DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
        .collection('services')
        .doc(request.serviceId)
        .get();
    if (!serviceDoc.exists || serviceDoc.data() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service details not found.')),
      );
      return;
    }
    ServiceModel service =
        ServiceModel.fromJson(serviceDoc.data() as Map<String, dynamic>);
    double amount = service.price ?? 0.0;

    final Map<String, dynamic> paymentData = {
      'amount': amount,
      'currency': 'TND',
      'order_id': request.bookingRequestId,
      "note": "Order #123",
      "first_name": "John",
      "last_name": "Doe",
      "email": "test@paymee.tn",
      "phone": "+21611222333",
      "return_url":
          "https://www.return_url.tn", // Replace with actual return URL
      "cancel_url":
          "https://www.cancel_url.tn", // Replace with actual cancel URL
      "webhook_url":
          "https://www.webhook_url.tn", // Replace with actual webhook URL

      'description': 'Payment for service ${service.title}',
      // Added webhook_url - Placeholder URL, replace if needed
    };

    try {
      final response = await http.post(
        Uri.parse(createPaymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $apiKey', // Include API key in header
        },
        body: json.encode(paymentData),
      );

      debugPrint(
          'Paymee API Request URL: ${response.request?.url}'); // Log the request URL
      debugPrint(
          'Response status code: ${response.statusCode}'); // Log the status code

      debugPrint('Paymee API Response BODY: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint(
            'Paymee API Response DATA: $responseData'); // Log response data

        if (responseData['status'] == true) {
          final String checkoutUrl = responseData['data']['payment_url'];

          debugPrint('Payment URL: $checkoutUrl');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebviewPage(
                orderId: request.bookingRequestId!,
                paymentUrl: checkoutUrl,
              ),
            ),
          );
        } else {
          if (!mounted) {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentErrorPage(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Payment failed: ${responseData['message'] ?? 'Unknown error'}'),
            ),
          );
        }
      } else {
        if (!mounted) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentErrorPage(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to create payment. Response code: ${response.statusCode}')),
        );
        debugPrint('response code: ${response.statusCode}');
        debugPrint('response body: ${response.body}');
      }
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating online payment: $error')),
      );
    }
  }

  void _completeOrder(BuildContext context, BookingRequestModel request) async {
    // Corrected method name
    try {
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(request.bookingRequestId)
          .update({'status': 'completed'});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated to completed.')),
      );
      setState(() {}); // Refresh the UI
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $error')),
      );
    }
  }

  void _completeOrderAndRating(
      // Corrected method name
      BuildContext context,
      BookingRequestModel request,
      double rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(request.bookingRequestId)
          .update({
        'status': 'finished',
        'paymentMethod': 'cash', // Assuming cash payment
        'userRating': rating, // Save user rating
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order completed and rated.')),
      );
      setState(() {}); // Refresh the UI
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing order and rating: $error')),
      );
    }
  }
}
