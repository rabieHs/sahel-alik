import 'package:flutter/material.dart';

class PaymentErrorPage extends StatelessWidget {
  const PaymentErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Failed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Payment Failed or Cancelled',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the orders tab or home
                Navigator.popUntil(
                    context,
                    ModalRoute.withName(
                        '/searcherHome')); // Adjust route name if needed
              },
              child: const Text('Back to Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
