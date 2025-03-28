import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../../../models/service.dart';

class BookingScreen extends StatelessWidget {
  static const routeName = '/booking_screen';
  final ServiceModel service;

  const BookingScreen({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${service.title}'), // Display service title
      ),
      body: Center(
        child: Text(
            'Booking Screen Content for ${service.title}'), // Display service title
      ),
    );
  }
}
