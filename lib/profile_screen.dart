import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import all the screens here
import 'orders_screen.dart';
import 'wallet_history_screen.dart';
import 'products_screen.dart';
import 'stock_management_screen.dart';
import 'product_upload_screen.dart';
// ignore: unused_import
import 'widgets/banner_widget.dart';
import 'widgets/widget_one.dart';
import 'widgets/widget_two.dart';
import 'widgets/profile_menu.dart';
import 'widgets/upload_graph.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String _shopName = 'Guest';

  // Variables to control whether widgets are visible or not
  // ignore: unused_field
  final bool _showBanner = false;
  final bool _showWidgetOne = true;
  final bool _showWidgetTwo = true;

  @override
  void initState() {
    super.initState();
    _fetchShopName();
  }

  void _fetchShopName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(uid)
            .get();
        if (vendorSnapshot.exists) {
          setState(() {
            _shopName = vendorSnapshot.get('shopName') ?? 'Guest';
          });
        } else {
          // Vendor document does not exist
          setState(() {
            _shopName = 'Guest';
          });
        }
      } else {
        // User not logged in
        setState(() {
          _shopName = 'Guest';
        });
      }
    } catch (e) {
      // Handle errors gracefully
      setState(() {
        _shopName = 'Guest';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Enable drawer button
        backgroundColor: const Color(0xFF31135F),
        iconTheme: const IconThemeData(
            color: Colors.white), // Set drawer icon color to white
        title: _buildAppBarTitle(),
      ),
      drawer: const ProfileMenu(), // Use the ProfileMenu here
      body: ListView(
        padding: EdgeInsets.zero, // Remove default padding
        children: [
          _buildAddProductButton(), // Add Product button at the top
          const UploadGraph(), // Permanent space for the UploadGraph widget
          _buildBigButtons(), // Big buttons in the main view
          if (_showWidgetOne || _showWidgetTwo) _buildBottomWidgets(),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _shopName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddProductButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF31135F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProductUploadScreen()),
            );
          },
          child: const Text(
            'Add Product',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBigButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildMenuButton('Orders', Icons.shopping_cart_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            );
          }),
          _buildMenuButton('Wallet', Icons.account_balance_wallet_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WalletHistoryScreen()),
            );
          }),
          _buildMenuButton('Products', Icons.production_quantity_limits, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductsScreen()),
            );
          }),
          _buildMenuButton('Stock Management', Icons.inventory_2_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const StockManagementScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF31135F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomWidgets() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_showWidgetOne)
            const WidgetOne(), // Conditionally show Widget One
          if (_showWidgetTwo)
            const WidgetTwo(), // Conditionally show Widget Two
        ],
      ),
    );
  }
}
