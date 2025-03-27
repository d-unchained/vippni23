import 'package:flutter/material.dart';

class WidgetTwo extends StatelessWidget {
  const WidgetTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 40, color: Color(0xFF31135F)),
            SizedBox(height: 8.0),
            Text(
              'Widget 2',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
