import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditImagesContent extends StatelessWidget {
  final List<String> images;
  final VoidCallback onEditPressed;

  const EditImagesContent({
    super.key,
    required this.images,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onEditPressed,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Images'),
        ),
        const SizedBox(height: 10),
        images.isNotEmpty
            ? Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(images.length, (index) {
                  return Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: images[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              )
            : const Text('No images selected.'),
      ],
    );
  }
}
