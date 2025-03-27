import 'package:flutter/material.dart';

class ShippingPolicyScreen extends StatelessWidget {
  const ShippingPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Policy'),
      ),
      body: const Center(
        child: Text('This is the Shipping Policy Screen'),
      ),
    );
  }
}
