import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        tabs: [
          Tab(text: AppLocalizations.of(context)!.pending),
          Tab(text: AppLocalizations.of(context)!.priceConfirmation),
          Tab(text: AppLocalizations.of(context)!.active),
          Tab(text: AppLocalizations.of(context)!.completed),
          Tab(text: AppLocalizations.of(context)!.finished),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab('pending'),
          _buildOrdersTab('price_request'), // Added price_request tab
          _buildOrdersTab('active'),
          _buildOrdersTab('completed'),
          _buildOrdersTab('finished'),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(String status) {
    return FutureBuilder<List<BookingRequestModel>>(
      future: _fetchBookingRequests(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(
              child: Text(AppLocalizations.of(context)!.noOrdersFound));
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
                    Text(
                        '${AppLocalizations.of(context)!.requestId}: ${request.bookingRequestId}'),
                    Text(
                        '${AppLocalizations.of(context)!.serviceId}: ${request.serviceId}'),
                    Text(
                        '${AppLocalizations.of(context)!.dateAndTime}: ${request.dateTime}'),
                    Text(
                        '${AppLocalizations.of(context)!.description}: ${request.description}'),
                    if (request.status == 'price_request')
                      Text(
                          '${AppLocalizations.of(context)!.providerPrice}: ${request.price}'),
                    Text(
                        '${AppLocalizations.of(context)!.userRating}: ${request.paymentMethod == 'cash' && request.status == 'finished' ? AppLocalizations.of(context)!.youRated('${request.userRating ?? _rating}') : AppLocalizations.of(context)!.notRatedYet}'),
                    Text(
                        '${AppLocalizations.of(context)!.status}: ${request.status}'),
                    const SizedBox(height: 10),
                    if (request.status == 'price_request')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _confirmPrice(context, request);
                            },
                            child: Text(
                                AppLocalizations.of(context)!.confirmPrice),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _rejectPrice(context, request);
                            },
                            child:
                                Text(AppLocalizations.of(context)!.rejectPrice),
                          ),
                        ],
                      ),
                    if (request.status == 'completed')
                      CustomButton(
                        text: AppLocalizations.of(context)!.pay,
                        onPressed: () {
                          _showPaymentDialog(context, request);
                        },
                      ),
                    if (request.status == 'active')
                      CustomButton(
                        text: AppLocalizations.of(context)!.completeOrder,
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

      if (status != 'all' && status != 'price_request') {
        query = query.where('status', isEqualTo: status);
      } else if (status == 'price_request') {
        query = query.where('status', isEqualTo: status);
      }

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
          title: Text(AppLocalizations.of(context)!.paymentOptions),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(AppLocalizations.of(context)!.payWithCash),
                onTap: () {
                  Navigator.pop(context);
                  _payWithCash(context, request);
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.payOnline),
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
          title: Text(AppLocalizations.of(context)!.payWithCash),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.of(context)!.rateServiceReceived),
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
                text: AppLocalizations.of(context)!.confirmPayment,
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
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.paymentRequestedStatus)),
      );
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .errorRequestingPayment(error.toString()))),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.userNotLoggedIn)),
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
        SnackBar(
            content: Text(AppLocalizations.of(context)!.userProfileNotFound)),
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
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.serviceDetailsNotFound)),
      );
      return;
    }
    ServiceModel service =
        ServiceModel.fromJson(serviceDoc.data() as Map<String, dynamic>);
    double amount = request.price ?? 0.0;

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
                  providerId: request.providerId!,
                  price: request.price ?? 0.0),
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
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .errorInitiatingOnlinePayment(error.toString()))),
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
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.orderStatusUpdatedCompleted)),
      );
      setState(() {}); // Refresh the UI
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .errorUpdatingOrderStatus(error.toString()))),
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
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.orderCompletedAndRated)),
      );
      setState(() {}); // Refresh the UI
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .errorCompletingOrderAndRating(error.toString()))),
      );
    }
  }

  Future<void> _confirmPrice(
      BuildContext context, BookingRequestModel request) async {
    await FirebaseFirestore.instance
        .collection('booking_requests')
        .doc(request.bookingRequestId)
        .update({'status': 'active'});
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.priceConfirmed)),
    );
  }

  Future<void> _rejectPrice(
      BuildContext context, BookingRequestModel request) async {
    await FirebaseFirestore.instance
        .collection('booking_requests')
        .doc(request.bookingRequestId)
        .update({'status': 'pending'});
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.priceRejected)),
    );
  }
}
