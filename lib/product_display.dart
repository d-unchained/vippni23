import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDisplay extends StatefulWidget {
  final String productId;
  final String backButtonLabel;

  const ProductDisplay({
    required this.productId,
    this.backButtonLabel = 'Back to Products',
    super.key,
  });

  @override
  ProductDisplayState createState() => ProductDisplayState();
}

class ProductDisplayState extends State<ProductDisplay> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: const Color(0xFF31135F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching product data: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Product not found'),
            );
          } else {
            final productData = snapshot.data!.data()!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: _buildProductDetails(productData),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProductDetails(Map<String, dynamic> productData) {
    // Extract fields from productData
    final String name = productData['name'] ?? '';
    final String description = productData['description'] ?? '';
    final double price = (productData['price'] as num?)?.toDouble() ?? 0.0;
    final double? rrp = (productData['rrp'] as num?)?.toDouble();
    final double? salePrice = (productData['salePrice'] as num?)?.toDouble();
    final bool isOnSale = productData['isOnSale'] ?? false;
    final int quantity = productData['quantity'] ?? 0;
    final String barcode = productData['barcode'] ?? '';
    final String type = productData['type'] ?? '';
    final String availability = productData['availability'] ?? '';
    final double weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
    final String weightUnit = productData['weightUnit'] ?? '';
    final String dimensions = productData['dimensions'] ?? '';
    final String dimensionsUnit = productData['dimensionsUnit'] ?? '';
    final String packaging = productData['packaging'] ?? '';
    final List<dynamic> materials = productData['material'] ?? [];
    final List<dynamic> colors = productData['colors'] ?? [];
    final List<dynamic> tags = productData['tags'] ?? [];
    final List<dynamic> images = productData['images'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        images.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: images[0],
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : const Placeholder(fallbackHeight: 200),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          'Price: \$${price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (rrp != null)
          Text(
            'RRP: \$${rrp.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
        if (salePrice != null)
          Text(
            'Sale Price: \$${salePrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
        const SizedBox(height: 16),
        Text('On Sale: ${isOnSale ? 'Yes' : 'No'}'),
        const SizedBox(height: 8),
        Text('Quantity: $quantity'),
        const SizedBox(height: 8),
        Text('Barcode: $barcode'),
        const SizedBox(height: 8),
        Text('Type: $type'),
        const SizedBox(height: 8),
        Text('Availability: $availability'),
        const SizedBox(height: 8),
        Text('Weight: $weight $weightUnit'),
        const SizedBox(height: 8),
        Text('Dimensions: $dimensions $dimensionsUnit'),
        const SizedBox(height: 8),
        Text('Packaging: $packaging'),
        const SizedBox(height: 8),
        Text('Materials: ${materials.join(', ')}'),
        const SizedBox(height: 8),
        Text('Colors: ${colors.join(', ')}'),
        const SizedBox(height: 8),
        Text('Tags: ${tags.join(', ')}'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF31135F),
          ),
          child: Text(widget.backButtonLabel),
        ),
      ],
    );
  }
}
