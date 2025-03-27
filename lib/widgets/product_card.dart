import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../product_edit_screen.dart';

class ProductCard extends StatelessWidget {
  final DocumentSnapshot product;
  final Function(String) onDelete;
  final Function(String, int) onUpdateInventory;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onUpdateInventory,
  });

  @override
  Widget build(BuildContext context) {
    final productId = product.id;
    final productName = product['name'];
    final productImages = List<String>.from(product['images']);
    final productQuantity = product['quantity'];

    return Card(
      child: Column(
        children: [
          productImages.isNotEmpty
              ? Image.network(
                  productImages[0],
                  height: 100,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 100,
                  color: Colors.grey,
                  child: const Center(child: Text('No Image')),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(productName),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () {
                  if (productQuantity > 0) {
                    onUpdateInventory(productId, productQuantity - 1);
                  }
                },
              ),
              Text(productQuantity.toString()),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  onUpdateInventory(productId, productQuantity + 1);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductEditScreen(productId: productId),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmation(context, productId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(productId);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
