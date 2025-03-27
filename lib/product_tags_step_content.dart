import 'package:flutter/material.dart';

class ProductTagsStepContent extends StatelessWidget {
  final TextEditingController tagController;
  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<int> onRemoveTag;

  const ProductTagsStepContent({
    super.key,
    required this.tagController,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Enter a tag',
                child: TextFormField(
                  controller: tagController,
                  decoration: const InputDecoration(labelText: 'Add Tag'),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: onAddTag,
            ),
          ],
        ),
        for (var i = 0; i < tags.length; i++)
          Row(
            children: [
              Expanded(
                child: Text(tags[i]),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => onRemoveTag(i),
              ),
            ],
          ),
      ],
    );
  }
}
