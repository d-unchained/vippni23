import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/order_item_widget.dart'; // Import the widget
import 'orders_menu.dart'; // Import the OrdersMenu widget

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  OrdersScreenState createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vendorId =
      FirebaseAuth.instance.currentUser!.uid; // Get the vendor ID
  late TabController _tabController;
  bool _isLoading = true;
  late Future<List<QueryDocumentSnapshot>> _ordersFuture;
  late List<QueryDocumentSnapshot> _cachedOrders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // No need to call setState() for tab changes
    });
    _ordersFuture = _fetchOrders();
  }

  Future<List<QueryDocumentSnapshot>> _fetchOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();
      _cachedOrders = snapshot.docs;
      setState(() {
        _isLoading = false;
      });
      return _cachedOrders;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when the user is not logged in
      return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: const Center(
          child: Text('Please log in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF31135F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'On the Way'),
            Tab(text: 'Completed'),
          ],
          labelColor: Colors.white,
        ),
      ),
      drawer: const OrdersMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error fetching orders: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }
                final orders = _cachedOrders;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(orders, 'Pending'),
                    _buildOrdersList(orders, 'on the way'),
                    _buildOrdersList(orders, 'completed'),
                  ],
                );
              },
            ),
    );
  }

  // Build orders list by filtering items within the order by status
  Widget _buildOrdersList(
      List<QueryDocumentSnapshot> orders, String statusFilter) {
    final filteredOrders = orders.where((order) {
      final List<dynamic> items = order['items'];
      final vendorItems = items.where((item) {
        return item['vendorId'] == _vendorId && item['status'] == statusFilter;
      }).toList();
      return vendorItems.isNotEmpty;
    }).toList();

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final List<dynamic> items = order['items'];

        // Filter items based on status and vendorId
        final vendorItems = items.where((item) {
          return item['vendorId'] == _vendorId &&
              item['status'] == statusFilter;
        }).toList();

        // If products match, pass order data to the OrderItemWidget
        return OrderItemWidget(
          order: order,
          filteredItems: vendorItems,
        ); // Pass only filtered items
      },
    );
  }
}
