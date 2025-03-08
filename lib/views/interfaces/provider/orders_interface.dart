import 'package:flutter/material.dart';

class ProviderOrdersInterface extends StatelessWidget {
  const ProviderOrdersInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: const Center(
        child: Text('Orders Screen'),
      ),
    );
  }
}
