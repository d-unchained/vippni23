import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import '../product_display.dart';

class OrderDetailsWidget extends StatefulWidget {
  final DocumentSnapshot order;
  final dynamic item;

  const OrderDetailsWidget({
    super.key,
    required this.order,
    required this.item,
  });

  @override
  OrderDetailsWidgetState createState() => OrderDetailsWidgetState();
}

class OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  String? _selectedStatus; // Current status from database
  String? _newSelectedStatus; // Status selected from dropdown
  String? _productImageUrl;
  String? _trackingNumber;
  String? _shippingCost; // Optional shipping cost
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _userData;
  String? _orderId;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.item['status'];
    _newSelectedStatus =
        _selectedStatus; // Initialize dropdown with current status
    _orderId = widget.order.id;
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchProductData(),
      _fetchUserData(),
    ]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    final userId = widget.order['userId'];
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        _userData = userDoc.data();
      } else {
        _userData = {'fullName': 'Unknown', 'address': 'No Address Provided'};
      }
    } catch (e) {
      _userData = {'fullName': 'Unknown', 'address': 'No Address Provided'};
    }
  }

  Future<void> _fetchProductData() async {
    final productId = widget.item['productId'];
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        if (productData['images'] != null &&
            productData['images'] is List &&
            productData['images'].isNotEmpty) {
          _productImageUrl = productData['images'][0];
        } else {
          _productImageUrl = null;
        }
      } else {
        _productImageUrl = null;
      }
    } catch (e) {
      _productImageUrl = null;
    }
  }

  Future<void> _showConfirmationDialog() async {
    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content:
            const Text('Are you sure you want to update the order status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (shouldUpdate == true) {
      await _updateOrderStatus();
    }
  }

  Future<void> _updateOrderStatus() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      // Form is not valid, do not proceed
      return;
    }

    setState(() {
      _isUpdating = true;
    });
    try {
      final List<dynamic> items = widget.order['items'];
      for (var item in items) {
        if (item['productId'] == widget.item['productId']) {
          item['status'] = _newSelectedStatus;
          if (_trackingNumber != null && _trackingNumber!.isNotEmpty) {
            item['trackingNumber'] = _trackingNumber;
          }
          if (_shippingCost != null && _shippingCost!.isNotEmpty) {
            item['shippingCost'] = _shippingCost;
          }
          break;
        }
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'items': items});

      await _refreshOrderData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update order status')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _refreshOrderData() async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final updatedItem = (orderData['items'] as List<dynamic>).firstWhere(
            (item) => item['productId'] == widget.item['productId'],
            orElse: () => null);
        if (updatedItem != null) {
          setState(() {
            _selectedStatus = updatedItem['status']; // Update status displayed
            _newSelectedStatus = updatedItem['status']; // Reset dropdown
          });
        }
      }
    } catch (e) {
      // Handle error if necessary
      print('Error refreshing order data: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.yellow;
      case 'on the way':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderDate = widget.order['orderDate'].toDate();
    final formattedOrderTime =
        DateFormat('hh:mm a').format(orderDate); // Format the time

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Bar
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          color: _getStatusColor(_selectedStatus!),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ID: $_orderId',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Status: $_selectedStatus',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Order Time
                        Text('Order Time: $formattedOrderTime',
                            style: const TextStyle(fontSize: 16)),
                        const Divider(height: 30),
                        // Customer Details
                        Text(
                          'Customer Details',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Customer: ${_userData!['fullName']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Address: ${_userData!['address']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(height: 30),
                        // Product Details
                        Text(
                          'Product Details',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail Image
                            _productImageUrl != null
                                ? Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        _productImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 100,
                                    width: 100,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('No Image'),
                                  ),
                            const SizedBox(width: 20),
                            // Product Info and View Button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.item['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Navigate to ProductDisplay
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDisplay(
                                                productId:
                                                    widget.item['productId'],
                                                backButtonLabel:
                                                    'Back to Order Details',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('View'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text('Price: \$${widget.item['price']}',
                                      style: const TextStyle(fontSize: 16)),
                                  Text('Quantity: ${widget.item['quantity']}',
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        // Optional Shipping Cost Input
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Enter Shipping Cost (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _shippingCost = value;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Tracking Number Input
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Enter Tracking Number',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _trackingNumber = value;
                          },
                          validator: (value) {
                            if (_newSelectedStatus == 'on the way' &&
                                (value == null || value.isEmpty)) {
                              return 'Tracking number is required when status is "On the Way"';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          value: _newSelectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Update Order Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'on the way',
                              child: Text('On the Way'),
                            ),
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              _newSelectedStatus = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showConfirmationDialog,
                            child: const Text('Update Order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Loading Indicator
                if (_isUpdating)
                  Container(
                    color: Colors.black.withValues(alpha:0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }
}
