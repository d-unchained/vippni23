import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/product_card.dart';
import 'widgets/products_menu.dart';
import 'product_display.dart'; // Import the ProductDisplay widget

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vendorId =
      FirebaseAuth.instance.currentUser!.uid; // Updated to vendorId

  // Pagination variables
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Declare _products as final
  final List<DocumentSnapshot> _products = [];

  // Filter variable
  String _currentFilter = 'uploads'; // Default filter

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchProducts({bool isRefresh = false}) async {
    if (_isLoadingMore) return;

    if (isRefresh) {
      _lastDocument = null;
      _hasMore = true;
      _products.clear();
    }

    if (!_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      Query query = _firestore
          .collection('products')
          .where('vendorId', isEqualTo: _vendorId) // Updated to vendorId
          .orderBy('name')
          .limit(_limit);

      // Apply filter
      query = _applyFilter(query);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        setState(() {
          _products.addAll(querySnapshot.docs);
        });
      } else {
        _hasMore = false;
      }
    } catch (e) {
      // Handle errors gracefully
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Query _applyFilter(Query query) {
    switch (_currentFilter) {
      case 'uploads':
        // No additional filtering needed for 'uploads'
        return query;
      case 'under_review':
        return query.where('status', isEqualTo: 'under_review');
      case 'sold':
        return query.where('status', isEqualTo: 'sold');
      case 'on_sale':
        return query.where('status', isEqualTo: 'on_sale');
      case 'in_process':
        return query.where('status', isEqualTo: 'in_process');
      case 'cancelled':
        return query.where('status', isEqualTo: 'cancelled');
      case 'inventory':
        // For inventory, perhaps no additional filtering
        return query;
      default:
        return query;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchProducts();
    }
  }

  Future<void> _onRefresh() async {
    await _fetchProducts(isRefresh: true);
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      // Remove the product from the list
      setState(() {
        _products.removeWhere((doc) => doc.id == productId);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  Future<void> _updateInventory(String productId, int quantity) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'quantity': quantity});

      // Update the quantity locally
      int index = _products.indexWhere((doc) => doc.id == productId);
      if (index != -1) {
        // Fetch the updated document
        DocumentSnapshot updatedDoc = await _products[index].reference.get();

        // Update the local list inside setState
        setState(() {
          _products[index] = updatedDoc;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating inventory: $e')),
      );
    }
  }

  void _onMenuItemSelected(String menuOption) {
    setState(() {
      _currentFilter = menuOption;
    });
    _onRefresh(); // Refresh the product list with the new filter
  }

  void _navigateToProductDisplay(DocumentSnapshot product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDisplay(
          productId: product.id, // Pass the productId to ProductDisplay
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF31135F), // Match background color
        iconTheme:
            const IconThemeData(color: Colors.white), // Drawer icon color
        title: const Text(
          'My Products',
          style: TextStyle(
            color: Colors.white, // Title text color
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: ProductsMenu(
        onMenuItemSelected: _onMenuItemSelected,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _products.isEmpty && !_isLoadingMore
            ? const Center(child: Text('No products found.'))
            : GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                ),
                itemCount: _products.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _products.length) {
                    final product = _products[index];
                    return GestureDetector(
                      onTap: () => _navigateToProductDisplay(product),
                      child: ProductCard(
                        product: product,
                        onDelete: _deleteProduct,
                        onUpdateInventory: _updateInventory,
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
      ),
    );
  }
}
