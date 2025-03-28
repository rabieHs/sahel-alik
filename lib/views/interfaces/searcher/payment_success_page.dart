import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import 'searcher_home_interface.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? orderId;
  final Map<String, dynamic>? paymentResponse;

  const PaymentSuccessPage({
    Key? key,
    this.orderId,
    this.paymentResponse,
  }) : super(key: key);

  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  double _rating = 3.0; // Default rating value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Please rate the service you received:',
                textAlign: TextAlign.center,
              ),
              if (widget.paymentResponse != null &&
                  widget.paymentResponse!['data'] != null &&
                  widget.paymentResponse!['data']['order_id'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Order ID: ${widget.paymentResponse!['data']['order_id']}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (widget.paymentResponse != null &&
                  widget.paymentResponse!['data'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildPaymentDetail(
                        'Token', widget.paymentResponse!['data']['token']),
                    _buildPaymentDetail('Amount',
                        '${widget.paymentResponse!['data']['amount']}'),
                    _buildPaymentDetail('Name',
                        '${widget.paymentResponse!['data']['first_name']} ${widget.paymentResponse!['data']['last_name']}'),
                    _buildPaymentDetail(
                        'Email', widget.paymentResponse!['data']['email']),
                  ],
                ),
              const SizedBox(height: 20),
              RatingBar.builder(
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
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _completeOrderAndRating(context);
                },
                child: const Text('Submit Rating and Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$title: ${value ?? 'N/A'}',
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _completeOrderAndRating(BuildContext context) async {
    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();
      if (user == null) {
        // Handle case where user is not logged in
        return;
      }

      if (widget.orderId != null) {
        await FirebaseFirestore.instance
            .collection('booking_requests')
            .doc(widget.orderId)
            .update({
          'status': 'finished',
          'paymentMethod': 'online',
          'userRating': _rating,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order completed and rated.')),
        );
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SearcherHomeInterface()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing order and rating: $error')),
      );
    }
  }
}
