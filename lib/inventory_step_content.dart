import 'package:flutter/material.dart';

class InventoryStepContent extends StatelessWidget {
  final TextEditingController productQuantityController;
  final String selectedAvailability;
  final TextEditingController barcodeController;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onScanBarcode;

  const InventoryStepContent({
    super.key,
    required this.productQuantityController,
    required this.selectedAvailability,
    required this.barcodeController,
    required this.onAvailabilityChanged,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Tooltip(
          message: 'Enter the quantity of the product',
          child: TextFormField(
            controller: productQuantityController,
            decoration: const InputDecoration(
              labelText: 'Product Quantity *',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the product quantity';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
        ),
        Tooltip(
          message: 'Select the availability status of the product',
          child: DropdownButtonFormField<String>(
            value: selectedAvailability,
            items: ['Sold', 'Available', 'On Hold', 'Coming Soon']
                .map((String status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              onAvailabilityChanged(value!);
            },
            decoration:
                const InputDecoration(labelText: 'Product Availability'),
          ),
        ),
        Tooltip(
          message: 'Enter the barcode of the product',
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: onScanBarcode,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
