import 'package:flutter/material.dart';
import 'material_types.dart';

class ProductPropertiesStepContent extends StatelessWidget {
  final String? selectedMaterial;
  final List<String> materials;
  final List<String> colors;
  final TextEditingController colorController;
  final ValueChanged<String?> onMaterialChanged;
  final VoidCallback onAddMaterial;
  final ValueChanged<int> onRemoveMaterial;
  final VoidCallback onAddColor;
  final ValueChanged<int> onRemoveColor;

  const ProductPropertiesStepContent({
    super.key,
    required this.selectedMaterial,
    required this.materials,
    required this.colors,
    required this.colorController,
    required this.onMaterialChanged,
    required this.onAddMaterial,
    required this.onRemoveMaterial,
    required this.onAddColor,
    required this.onRemoveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Select a material',
                child: DropdownButtonFormField(
                  value: selectedMaterial,
                  items: MaterialTypes.materialTypes.map((String material) {
                    return DropdownMenuItem(
                      value: material,
                      child: Text(material),
                    );
                  }).toList(),
                  onChanged: onMaterialChanged,
                  decoration:
                      const InputDecoration(labelText: 'Select Material'),
                  // Removed the validator to make it optional
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: onAddMaterial,
            ),
          ],
        ),
        for (var i = 0; i < materials.length; i++)
          Row(
            children: [
              Expanded(
                child: Text(materials[i]),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => onRemoveMaterial(i),
              ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Enter a color',
                child: TextFormField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: 'Add Color',
                  ),
                  // Removed the validator to make it optional
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: onAddColor,
            ),
          ],
        ),
        for (var i = 0; i < colors.length; i++)
          Row(
            children: [
              Expanded(
                child: Text(colors[i]),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => onRemoveColor(i),
              ),
            ],
          ),
      ],
    );
  }
}
