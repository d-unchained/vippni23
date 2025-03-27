import 'package:flutter/material.dart';
import 'product_types.dart';

class ProductDetailsStepContent extends StatelessWidget {
  final String? selectedProductType;
  final TextEditingController productNameController;
  final TextEditingController productDescriptionController;
  final ValueChanged<String?> onProductTypeChanged;

  const ProductDetailsStepContent({
    super.key,
    required this.selectedProductType,
    required this.productNameController,
    required this.productDescriptionController,
    required this.onProductTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Tooltip(
          message: 'Select the type of product',
          child: DropdownButtonFormField(
            value: selectedProductType,
            items: ProductTypes.productTypes.map((String type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: onProductTypeChanged,
            decoration: const InputDecoration(
              labelText: 'Product Type *',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a product type';
              }
              return null;
            },
          ),
        ),
        Tooltip(
          message: 'Enter the name of the product',
          child: TextFormField(
            controller: productNameController,
            decoration: const InputDecoration(
              labelText: 'Product Name *',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the product name';
              }
              return null;
            },
          ),
        ),
        Tooltip(
          message: 'Enter a detailed description of the product',
          child: TextFormField(
            controller: productDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Product Description *',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the product description';
              }
              if (value.length < 5) {
                return 'Description must be at least 5 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
