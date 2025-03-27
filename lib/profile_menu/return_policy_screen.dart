import 'package:flutter/material.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Policy'),
      ),
      body: const Center(
        child: Text('This is the Return Policy Screen'),
      ),
    );
  }
}
