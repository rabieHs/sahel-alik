import 'package:flutter/material.dart';
import 'searcher_home_interface.dart';

class PaymentErrorPage extends StatelessWidget {
  final Map<String, dynamic>? paymentResponse;

  const PaymentErrorPage({Key? key, this.paymentResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Failed'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error_outline, color: Colors.red, size: 100),
              const SizedBox(height: 20),
              const Text(
                'Payment Failed or Cancelled',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SearcherHomeInterface()), // Navigate to searcher home
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
