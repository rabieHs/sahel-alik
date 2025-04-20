import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_button.dart';
import '../../../services/auth_service.dart';
import '../../../models/booking_request.dart';
import '../../../utils/validation_utils.dart';

enum PaymentMethod { cash, online }

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String providerId;

  const BookingScreen({
    super.key,
    required this.serviceId,
    required this.providerId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDateTime;
  final TextEditingController _descriptionController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash; // Default to cash
  bool _isLoading = false;

  void _selectDateTime(BuildContext context) {
    // Use a synchronous approach to avoid BuildContext issues
    _showDatePicker(context);
  }

  Future<void> _showDatePicker(BuildContext context) async {
    if (!mounted) return;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null && mounted) {
      // Store the date and show time picker in the next frame
      final selectedDate = pickedDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showTimePicker(context, selectedDate);
        }
      });
    }
  }

  Future<void> _showTimePicker(
      BuildContext context, DateTime pickedDate) async {
    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
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

  Future<void> _sendBookingRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateTime == null) {
      _showSnackBar(AppLocalizations.of(context)!.dateTimeRequired);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();
      if (user == null) {
        // This should not happen as we check for user login before navigating here
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.userNotLoggedIn);
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

      // Update was successful, no need to get the booking request back

      if (!mounted) return;
      _showSnackBar('Booking request sent successfully!');
      Navigator.pop(context);
    } catch (e) {
      // Error logged
      if (!mounted) return;
      _showSnackBar('Failed to send booking request. Please try again.');
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date and Time Selection
                  InkWell(
                    onTap: () => _selectDateTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.dateAndTime,
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
                                  ? AppLocalizations.of(context)!
                                      .selectDateAndTime
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
                      labelText:
                          AppLocalizations.of(context)!.missionDescription,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) =>
                        ValidationUtils.validateBookingDescription(
                            value, context),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 30),

                  // Send Request Button
                  CustomButton(
                    text: AppLocalizations.of(context)!.sendRequest,
                    onPressed: _sendBookingRequest,
                    loading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(128),
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

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
