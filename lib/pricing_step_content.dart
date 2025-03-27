import 'package:flutter/material.dart';

class PricingStepContent extends StatelessWidget {
  final TextEditingController productPriceController;
  final TextEditingController rrpController;
  final TextEditingController salePriceController;
  final bool isOnSale;
  final ValueChanged<bool?> onIsOnSaleChanged;

  const PricingStepContent({
    super.key,
    required this.productPriceController,
    required this.rrpController,
    required this.salePriceController,
    required this.isOnSale,
    required this.onIsOnSaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Tooltip(
          message: 'Enter the price of the product',
          child: TextFormField(
            controller: productPriceController,
            decoration: const InputDecoration(
              labelText: 'Product Price *',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the product price';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
        ),
        Tooltip(
          message: 'Enter the recommended retail price of the product',
          child: TextFormField(
            controller: rrpController,
            decoration: const InputDecoration(
              labelText: 'RRP',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        Tooltip(
          message: 'Enter the sale price of the product',
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: salePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Sale Price',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Checkbox(
                value: isOnSale,
                onChanged: onIsOnSaleChanged,
              ),
              const Text('On Sale'),
            ],
          ),
        ),
      ],
    );
  }
}
