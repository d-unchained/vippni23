import 'dart:io';
import 'package:flutter/material.dart';

class ImageUploadStepContent extends StatelessWidget {
  final List<File> images;
  final VoidCallback onUploadPressed;

  const ImageUploadStepContent({
    super.key,
    required this.images,
    required this.onUploadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: IconButton(
            iconSize: 100,
            icon: const Icon(Icons.camera_alt),
            onPressed: onUploadPressed,
          ),
        ),
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(
              images.first,
              width: 100,
              height: 100,
            ),
          ),
      ],
    );
  }
}
