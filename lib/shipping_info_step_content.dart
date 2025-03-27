import 'package:flutter/material.dart';
import 'packaging_types.dart';

class ShippingInfoStepContent extends StatelessWidget {
  final String? selectedPackaging;
  final TextEditingController weightController;
  final String? weightUnit;
  final String dimensionsControllerText;
  final String dimensionsUnit;
  final VoidCallback onShowDimensionsDialog;
  final ValueChanged<String?> onPackagingChanged;
  final ValueChanged<String?> onWeightUnitChanged;

  const ShippingInfoStepContent({
    super.key,
    required this.selectedPackaging,
    required this.weightController,
    required this.weightUnit,
    required this.dimensionsControllerText,
    required this.dimensionsUnit,
    required this.onShowDimensionsDialog,
    required this.onPackagingChanged,
    required this.onWeightUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Tooltip(
          message: 'Select the packaging type',
          child: DropdownButtonFormField<String>(
            value: selectedPackaging,
            items: PackagingTypes.packagingTypes.map((String packaging) {
              return DropdownMenuItem<String>(
                value: packaging,
                child: Text(packaging),
              );
            }).toList(),
            onChanged: onPackagingChanged,
            decoration: const InputDecoration(labelText: 'Packaging *'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a packaging type';
              }
              return null;
            },
          ),
        ),
        Tooltip(
          message: 'Enter the weight of the product',
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight *',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0 || weight > 10000) {
                      return 'Please enter a valid weight between 1 gram and 10 kg';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: weightUnit ?? 'grams', // Default to 'grams' if null
                  items: ['grams', 'kg', 'ounces', 'carats', 'pounds']
                      .map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: onWeightUnitChanged,
                  decoration: const InputDecoration(labelText: 'Weight Unit *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a weight unit';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        if (selectedPackaging == 'Boxed')
          Tooltip(
            message: 'Enter the dimensions of the product',
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Dimensions *',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onShowDimensionsDialog,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the dimensions';
                }
                return null;
              },
              initialValue: dimensionsControllerText,
            ),
          ),
      ],
    );
  }
}
