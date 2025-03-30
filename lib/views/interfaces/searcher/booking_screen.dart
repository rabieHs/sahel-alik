import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_button.dart';
import '../../../services/auth_service.dart';
import '../../../models/booking_request.dart';
import '../../../models/service.dart';
import '../../widgets/custom_button.dart'; // Assuming you have ServiceModel

enum PaymentMethod { cash, online }

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String providerId;

  const BookingScreen({
    // Added const keyword
    Key? key, // Added Key? key
    required this.serviceId,
    required this.providerId,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDateTime;
  TextEditingController _descriptionController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash; // Default to cash
  bool _isLoading = false;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _sendBookingRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();
      if (user == null) {
        // This should not happen as we check for user login before navigating here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      if (_selectedDateTime == null || _descriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please select date/time and add description')),
        );
        return;
      }

      // Create booking request
      BookingRequestModel bookingRequest = BookingRequestModel(
        userId: user.uid,
        providerId: widget.providerId,
        serviceId: widget.serviceId,
        dateTime: _selectedDateTime,
        description: _descriptionController.text,
        paymentMethod: _paymentMethod.name, // Save payment method
        status: 'pending', // Set status based on payment method
        createdAt: Timestamp.now(),
      );

      // Send booking request to Firebase and get DocumentReference
      final DocumentReference bookingRequestRef = await FirebaseFirestore
          .instance
          .collection('booking_requests')
          .add(bookingRequest.toJson());

      // Update bookingRequestId with the document ID
      await bookingRequestRef
          .update({'bookingRequestId': bookingRequestRef.id});

      // Get the booking request back with the bookingRequestId
      final bookingRequestWithId = BookingRequestModel.fromJson(
          (await bookingRequestRef.get()).data() as Map<String, dynamic>);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking request sent successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error sending booking request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to send booking request. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Service'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date and Time Selection
                InkWell(
                  onTap: () => _selectDateTime(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date and Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _selectedDateTime == null
                                ? 'Select Date and Time'
                                : DateFormat('yyyy-MM-dd HH:mm')
                                    .format(_selectedDateTime!),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Method Selection
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Radio<PaymentMethod>(
                        value: PaymentMethod.cash,
                        groupValue: _paymentMethod,
                        onChanged: (PaymentMethod? value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      const Text('Cash'),
                      Radio<PaymentMethod>(
                        value: PaymentMethod.online,
                        groupValue: _paymentMethod,
                        onChanged: (PaymentMethod? value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      const Text('Online Payment'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mission Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                // Send Request Button
                CustomButton(
                  text: 'Send Request',
                  onPressed: _sendBookingRequest,
                  loading: _isLoading,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
