import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_details_widget.dart'; // Import the OrderDetailsWidget
import 'package:intl/intl.dart'; // Import intl for date formatting

class OrderItemWidget extends StatefulWidget {
  final DocumentSnapshot order;
  final List<dynamic> filteredItems; // Receive filtered items

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.filteredItems,
  });

  @override
  OrderItemWidgetState createState() => OrderItemWidgetState();
}

class OrderItemWidgetState extends State<OrderItemWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userFullName;
  String? _userCity;
  String? _userCountry;
  bool _isLoading = true;

  // Define color palette
  final Color primaryColor = const Color(0xFF31135F);
  final Color secondaryColor = const Color(0xFF6B29D1);
  final Color accentColor = const Color(0xFF4ABDFF);
  final Color cardBackgroundColor = const Color(0xFFD6F7FA);
  final Color buttonColor = const Color(0xFFFFB23D);
  final Color textColor = const Color(0xFF31135F);
  final Color subtitleColor = const Color(0xFF6B29D1);
  final Color dateBackgroundColor = const Color(0xFF6B29D1);

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final userId = widget.order['userId'];
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && mounted) {
          final addressMap = userData['address'] as Map<String, dynamic>?;
          setState(() {
            _userFullName = userData['fullName'] ?? 'Unknown Name';
            _userCity = addressMap?['city'] ?? 'Unknown City';
            _userCountry = addressMap?['country'] ?? 'Unknown Country';
          });
        }
      } else {
        setState(() {
          _userFullName = 'Unknown Name';
          _userCity = 'Unknown City';
          _userCountry = 'Unknown Country';
        });
      }
    } catch (e) {
      setState(() {
        _userFullName = 'Unknown Name';
        _userCity = 'Unknown City';
        _userCountry = 'Unknown Country';
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.filteredItems.isEmpty) {
      return const Center(child: Text('No products found for this vendor.'));
    }

    final orderDate = widget.order['orderDate'].toDate();
    final formattedDate = _formatDate(orderDate);

    return Column(
      children: widget.filteredItems.map((item) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailsWidget(order: widget.order, item: item),
              ),
            );
          },
          child: Card(
            color: cardBackgroundColor,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: secondaryColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Section takes full width
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: dateBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Order Date: $formattedDate',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Order No. line
                  Row(
                    children: [
                      Text(
                        'Order No:',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.order.id,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: accentColor,
                    thickness: 1,
                  ),
                  const SizedBox(height: 12),
                  // Product Information
                  Text(
                    'Product: ${item['name']}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Quantity and Price in one line
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Quantity: ${item['quantity']}',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Price: \$${(item['price'] as num).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: accentColor,
                    thickness: 1,
                  ),
                  const SizedBox(height: 12),
                  // Customer Information
                  Text(
                    'Customer: $_userFullName',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // City and Country in one line
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'City: $_userCity',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Country: $_userCountry',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
