import 'package:flutter/material.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 150.0,
      color: Colors.grey[300], // Temporary color for banner space
      child: const Center(
        child: Text(
          'Banner Widget Here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
