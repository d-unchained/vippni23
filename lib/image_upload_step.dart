import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:ui' as ui;
import 'package:image_background_remover/image_background_remover.dart';
import 'package:path_provider/path_provider.dart';

class ImageUploadStep extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  const ImageUploadStep({required this.onImagesSelected, super.key});

  @override
  ImageUploadStepState createState() => ImageUploadStepState();
}

class ImageUploadStepState extends State<ImageUploadStep> {
  final List<File> _images = [];
  final int _maxImages = 12;
  final bool _isUploading = false;
  int? _selectedIndex;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (_images.length >= _maxImages) {
        _showMaxImagesPopup();
        return;
      }

      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _cropImage(int index) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _images[index].path,
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
        setState(() {
          _images[index] = File(croppedFile.path);
        });
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
    final Uint8List imageBytes = await _images[index].readAsBytes();

    final ui.Image? outputImage = await BackgroundRemover.instance.removeBg(imageBytes);

    if (outputImage != null) {
      final byteData = await outputImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(
        '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png',
      ).writeAsBytes(pngBytes);

      setState(() {
        _images[index] = tempFile;
      });
    } else {
      _showErrorSnackBar('Background removal failed.');
    }
  } catch (e) {
    _showErrorSnackBar('Error removing background: $e');
  } finally {
    setState(() {
      _isProcessing = false;
    });
  }
}


  void _showErrorSnackBar(String error) {
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
      barrierDismissible: true,
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
                setState(() {
                  _images.removeAt(index);
                });
                Navigator.of(context).pop();
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
    setState(() {
      _selectedIndex = index;
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
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
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Images'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onImagesSelected(_images);
            Navigator.pop(context, _images);
          },
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
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final File item = _images.removeAt(oldIndex);
                              _images.insert(newIndex, item);
                            });
                          },
                          children: _images.map((file) {
                            int index = _images.indexOf(file);
                            return Container(
                              key: ValueKey(file.path),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: index == 0
                                      ? Colors.yellow
                                      : (index == _selectedIndex
                                          ? Colors.blue
                                          : Colors.red),
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.file(
                                          file,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3 -
                                              10,
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3 -
                                              10,
                                          fit: BoxFit.cover,
                                        ),
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
                                    width:
                                        MediaQuery.of(context).size.width / 3 -
                                            10,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                _showImageOptions(index),
                                          ),
                                        ),
                                        Expanded(
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _showRemoveConfirmationDialog(
                                                    index),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
                            onPressed: () {
                              widget.onImagesSelected(_images);
                              Navigator.pop(context, _images);
                            },
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
  final List<File> images;
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
            setState(() {
              _currentIndex = index;
            });
          },
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: FileImage(widget.images[index]),
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
