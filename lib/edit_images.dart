// edit_images.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:ui' as ui;
import 'package:image_background_remover/image_background_remover.dart';
import 'package:path_provider/path_provider.dart';

class EditableImage {
  String? url; // For existing images
  File? file; // For new images

  EditableImage({this.url, this.file});
}

class EditImages extends StatefulWidget {
  final List<String> initialImages; // List of image URLs from Firestore
  final Function(List<String>) onImagesUpdated;

  const EditImages({
    required this.initialImages,
    required this.onImagesUpdated,
    super.key,
  });

  @override
  EditImagesState createState() => EditImagesState();
}

class EditImagesState extends State<EditImages> {
  List<EditableImage> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isProcessing = false;
  int? _selectedIndex;
  final int _maxImages = 12;

  @override
  void initState() {
    super.initState();
    BackgroundRemover.instance.initializeOrt();
    // Initialize _images with existing image URLs
    _images =
        widget.initialImages.map((url) => EditableImage(url: url)).toList();
  }

  @override
  void dispose() {
    super.dispose();
    // Any additional cleanup if necessary
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= _maxImages) {
      _showMaxImagesPopup();
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _images.add(EditableImage(file: File(pickedFile.path)));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _cropImage(int index) async {
    try {
      final image = _images[index];
      String? path;

      if (image.file != null) {
        path = image.file!.path;
      } else if (image.url != null) {
        // Download the image to a temporary file for cropping
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png');
        final ref = FirebaseStorage.instance.refFromURL(image.url!);
        await ref.writeToFile(tempFile);
        path = tempFile.path;
      }

      if (path != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedFile != null) {
          if (!mounted) return;
          setState(() {
            _images[index] = EditableImage(file: File(croppedFile.path));
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error cropping image: $e');
    }
  }

Future<void> _removeBackground(int index) async {
  setState(() {
    _isProcessing = true;
  });

  try {
    final image = _images[index];
    Uint8List imageBytes;

    if (image.file != null) {
      imageBytes = await image.file!.readAsBytes();
    } else if (image.url != null) {
      final ref = FirebaseStorage.instance.refFromURL(image.url!);
      imageBytes = (await ref.getData())!;
    } else {
      _showErrorSnackBar('No image to process');
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    final ui.Image? outputImage = await BackgroundRemover.instance.removeBg(imageBytes);

    if (outputImage != null) {
      final byteData = await outputImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(
        '${tempDir.path}/bg_removed_${DateTime.now().millisecondsSinceEpoch}.png',
      ).writeAsBytes(pngBytes);

      if (!mounted) return;
      setState(() {
        _images[index] = EditableImage(file: tempFile);
      });
    } else {
      _showErrorSnackBar('Background removal failed.');
    }
  } catch (e) {
    _showErrorSnackBar('Error removing background: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    _updateImages();
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final EditableImage item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
    _updateImages();
  }

  Future<void> _uploadNewImages() async {
    setState(() {
      _isUploading = true;
    });

    try {
      for (int i = 0; i < _images.length; i++) {
        final image = _images[i];
        if (image.file != null) {
          String fileName =
              'products/${DateTime.now().millisecondsSinceEpoch}_${image.file!.path.split('/').last}';
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child(fileName)
              .putFile(image.file!);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          // Replace the EditableImage with one that has the URL
          _images[i] = EditableImage(url: downloadUrl);
        }
      }
      _updateImages();
    } catch (e) {
      _showErrorSnackBar('Error uploading images: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _updateImages() {
    final imageUrls =
        _images.map((image) => image.url).whereType<String>().toList();
    widget.onImagesUpdated(imageUrls);
  }

  void _showErrorSnackBar(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(child: Text(error)),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoveConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // User can dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: const Text('Are you sure you want to remove this image?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteImage(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFullScreenImage(int initialIndex) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: FullScreenImageGallery(
            images: _images,
            initialIndex: initialIndex,
          ),
        ),
      ),
    );
  }

  Future<void> _showImageOptions(int index) async {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // User can dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Options'),
          actions: <Widget>[
            TextButton(
              child: const Text('View Full Screen'),
              onPressed: () {
                Navigator.of(context).pop();
                _showFullScreenImage(index);
              },
            ),
            TextButton(
              child: const Text('Crop Image'),
              onPressed: () {
                Navigator.of(context).pop();
                _cropImage(index);
              },
            ),
            TextButton(
              child: const Text('Remove Background'),
              onPressed: () {
                Navigator.of(context).pop();
                _removeBackground(index);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _selectedIndex = null;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMaxImagesPopup() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Maximum Images Reached'),
          content: const Text('You can only upload a maximum of 12 images.'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSave() async {
    // Upload new images and update the image URLs
    await _uploadNewImages();
    if (!mounted) return;
    Navigator.pop(context); // Close the Edit Images screen
  }

  Widget _buildImageItem(EditableImage image, int index) {
    Widget imageWidget;

    if (image.file != null) {
      imageWidget = Image.file(
        image.file!,
        width: MediaQuery.of(context).size.width / 3 - 10,
        height: MediaQuery.of(context).size.width / 3 - 10,
        fit: BoxFit.cover,
      );
    } else if (image.url != null) {
      imageWidget = Image.network(
        image.url!,
        width: MediaQuery.of(context).size.width / 3 - 10,
        height: MediaQuery.of(context).size.width / 3 - 10,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = const Placeholder();
    }

    return Container(
      key: ValueKey(image.url ?? image.file?.path),
      decoration: BoxDecoration(
        border: Border.all(
          color: index == 0
              ? Colors.yellow
              : (index == _selectedIndex ? Colors.blue : Colors.red),
          width: 3,
        ),
        boxShadow: [
          if (_selectedIndex == index)
            BoxShadow(
              color: Colors.blue.withValues(alpha:0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imageWidget,
              ),
              if (index == 0)
                const Positioned(
                  top: 5,
                  right: 5,
                  child: Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 30,
                  ),
                ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3 - 10,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showImageOptions(index),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _showRemoveConfirmationDialog(index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Images'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onSave,
        ),
      ),
      body: _isUploading || _isProcessing
          ? Center(
              child: SpinKitCircle(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: ReorderableWrap(
                          needsLongPressDraggable: false,
                          spacing: 4.0,
                          runSpacing: 4.0,
                          maxMainAxisCount: 3,
                          onReorder: _reorderImages,
                          children: List.generate(_images.length, (index) {
                            return _buildImageItem(_images[index], index);
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: _onSave,
                            iconSize: 30,
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.blue),
                            onPressed: () => _pickImage(ImageSource.camera),
                            iconSize: 30,
                          ),
                          IconButton(
                            icon: const Icon(Icons.photo_library,
                                color: Colors.blue),
                            onPressed: () => _pickImage(ImageSource.gallery),
                            iconSize: 30,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Star icon = Display Image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<EditableImage> images;
  final int initialIndex;

  const FullScreenImageGallery({
    required this.images,
    required this.initialIndex,
    super.key,
  });

  @override
  FullScreenImageGalleryState createState() => FullScreenImageGalleryState();
}

class FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoViewGallery.builder(
          itemCount: widget.images.length,
          pageController: _pageController,
          onPageChanged: (index) {
            if (!mounted) return;
            setState(() {
              _currentIndex = index;
            });
          },
          builder: (context, index) {
            final image = widget.images[index];
            ImageProvider imageProvider;
            if (image.file != null) {
              imageProvider = FileImage(image.file!);
            } else if (image.url != null) {
              imageProvider = NetworkImage(image.url!);
            } else {
              imageProvider = const AssetImage('assets/placeholder.png');
            }
            return PhotoViewGalleryPageOptions(
              imageProvider: imageProvider,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            '${_currentIndex + 1}/${widget.images.length}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Positioned(
          left: 10,
          top: MediaQuery.of(context).size.height / 2 - 30,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () {
              if (_currentIndex > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ),
        Positioned(
          right: 10,
          top: MediaQuery.of(context).size.height / 2 - 30,
          child: IconButton(
            icon:
                const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
            onPressed: () {
              if (_currentIndex < widget.images.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
