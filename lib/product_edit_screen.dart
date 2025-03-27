import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'edit_images.dart';
import 'product_display.dart';
import 'edit_images_content.dart';
import 'product_details_step_content.dart';
import 'inventory_step_content.dart';
import 'pricing_step_content.dart';
import 'shipping_info_step_content.dart';
import 'product_properties_step_content.dart';
import 'product_tags_step_content.dart';

class ProductEditScreen extends StatefulWidget {
  final String productId;

  const ProductEditScreen({required this.productId, super.key});

  @override
  ProductEditScreenState createState() => ProductEditScreenState();
}

class ProductEditScreenState extends State<ProductEditScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _rrpController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  // Variables
  String? _weightUnit;
  String _dimensionsUnit = 'cm';
  String? _selectedProductType;
  String _selectedAvailability = 'Available';
  String? _selectedMaterial;
  String? _selectedPackaging;
  List<String> _images = [];
  List<String> _colors = [];
  List<String> _tags = [];
  List<String> _materials = [];
  bool _isOnSale = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(widget.productId).get();
      if (productSnapshot.exists) {
        var productData = productSnapshot.data() as Map<String, dynamic>;
        if (!mounted) return; // Ensure widget is still mounted
        setState(() {
          _productNameController.text = productData['name'] as String? ?? '';
          _productDescriptionController.text =
              productData['description'] as String? ?? '';
          _productPriceController.text =
              (productData['price']?.toString()) ?? '';
          _rrpController.text = (productData['rrp']?.toString()) ?? '';
          _salePriceController.text =
              (productData['salePrice']?.toString()) ?? '';
          _isOnSale = productData['isOnSale'] as bool? ?? false;
          _productQuantityController.text =
              (productData['quantity']?.toString()) ?? '0';
          _barcodeController.text = (productData['barcode']?.toString()) ?? '';
          _selectedProductType = productData['type'] as String?;
          _selectedAvailability =
              productData['availability'] as String? ?? 'Available';
          _weightController.text = (productData['weight']?.toString()) ?? '';
          _weightUnit = productData['weightUnit'] as String?;
          _dimensionsController.text =
              (productData['dimensions'] as String?) ?? '';
          _dimensionsUnit = productData['dimensionsUnit'] as String? ?? 'cm';
          _selectedPackaging = productData['packaging'] as String?;

          // Normalize fields to List<String>
          _materials = _normalizeToListString(productData['material']);
          _colors = _normalizeToListString(productData['colors']);
          _tags = _normalizeToListString(productData['tags']);
          _images = _normalizeToListString(productData['images']);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product: $e')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveProduct({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) {
      for (int i = 0; i < _steps().length; i++) {
        if (!_isStepComplete(i)) {
          setState(() {
            _currentStep = i;
          });
          return;
        }
      }
      return;
    }

    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one material')),
      );
      setState(() {
        _currentStep = _steps().indexWhere((step) {
          if (step.title is Text) {
            final Text titleWidget = step.title as Text;
            return titleWidget.data == 'Product Properties';
          }
          return false;
        });
      });
      return;
    }

    if (_colors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one color')),
      );
      setState(() {
        _currentStep = _steps().indexWhere((step) {
          if (step.title is Text) {
            final Text titleWidget = step.title as Text;
            return titleWidget.data == 'Product Properties';
          }
          return false;
        });
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final productData = {
        'name': _productNameController.text,
        'description': _productDescriptionController.text,
        'price': double.parse(_productPriceController.text),
        'rrp': _rrpController.text.isNotEmpty
            ? double.parse(_rrpController.text)
            : null,
        'salePrice': _salePriceController.text.isNotEmpty
            ? double.parse(_salePriceController.text)
            : null,
        'isOnSale': _isOnSale,
        'quantity': int.parse(_productQuantityController.text),
        'barcode': _barcodeController.text,
        'type': _selectedProductType,
        'availability': _selectedAvailability,
        'weight': double.parse(_weightController.text),
        'weightUnit': _weightUnit,
        'dimensions': _dimensionsController.text,
        'dimensionsUnit': _dimensionsUnit,
        'packaging': _selectedPackaging,
        'material': _materials,
        'colors': _colors,
        'tags': _tags,
        'images': _images, // Ensure this is always a List<String>
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'isDraft': isDraft,
      };

      await _firestore
          .collection('products')
          .doc(widget.productId)
          .update(productData);

      if (!isDraft) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDisplay(
              productId: widget.productId,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDimensionsDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Dimensions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: _lengthController,
                  decoration: const InputDecoration(labelText: 'Length'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _widthController,
                  decoration: const InputDecoration(labelText: 'Width'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Height'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: _dimensionsUnit,
                  items: ['cm', 'mm', 'inches'].map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (!mounted) return;
                    setState(() {
                      _dimensionsUnit = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _dimensionsController.text =
                      '${_lengthController.text} x ${_widthController.text} x ${_heightController.text}';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditImages() async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Images'),
            backgroundColor: const Color(0xFF31135F),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: EditImages(
            initialImages: _images,
            onImagesUpdated: (updatedImages) {
              if (mounted) {
                setState(() {
                  _images = updatedImages;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (!mounted) return;
      setState(() {
        _barcodeController.text = result.rawContent;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning barcode: $e')),
      );
    }
  }

  void _resetForm() {
    if (!mounted) return;
    setState(() {
      _productNameController.clear();
      _productDescriptionController.clear();
      _productPriceController.clear();
      _rrpController.clear();
      _salePriceController.clear();
      _productQuantityController.clear();
      _barcodeController.clear();
      _weightController.clear();
      _dimensionsController.clear();
      _lengthController.clear();
      _widthController.clear();
      _heightController.clear();
      _colorController.clear();
      _tagController.clear();
      _images.clear();
      _colors.clear();
      _tags.clear();
      _materials.clear();
      _selectedProductType = null;
      _selectedAvailability = 'Available';
      _selectedMaterial = null;
      _weightUnit = null;
      _dimensionsUnit = 'cm';
      _selectedPackaging = null;
      _isOnSale = false;
      _currentStep = 0;
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _rrpController.dispose();
    _salePriceController.dispose();
    _productQuantityController.dispose();
    _barcodeController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _colorController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  bool _isStepComplete(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return _images.isNotEmpty;
      case 1:
        return _selectedProductType != null &&
            _productNameController.text.isNotEmpty &&
            _productDescriptionController.text.isNotEmpty;
      case 2:
        return _productQuantityController.text.isNotEmpty &&
            _selectedAvailability.isNotEmpty;
      case 3:
        return _productPriceController.text.isNotEmpty;
      case 4:
        return _selectedPackaging != null &&
            _weightController.text.isNotEmpty &&
            _weightUnit != null &&
            (_selectedPackaging != 'Boxed' ||
                _dimensionsController.text.isNotEmpty);
      case 5:
        return _materials.isNotEmpty && _colors.isNotEmpty;
      default:
        return true;
    }
  }

  List<Step> _steps() => [
        Step(
          title: const Text('Upload Images'),
          content: EditImagesContent(
            images: _images,
            onEditPressed: _navigateToEditImages,
          ),
          isActive: _currentStep >= 0,
          state: _images.isNotEmpty ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Product Details'),
          content: ProductDetailsStepContent(
            selectedProductType: _selectedProductType,
            productNameController: _productNameController,
            productDescriptionController: _productDescriptionController,
            onProductTypeChanged: (value) {
              setState(() {
                _selectedProductType = value;
              });
            },
          ),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Inventory'),
          content: InventoryStepContent(
            productQuantityController: _productQuantityController,
            selectedAvailability: _selectedAvailability,
            barcodeController: _barcodeController,
            onAvailabilityChanged: (value) {
              setState(() {
                _selectedAvailability = value;
              });
            },
            onScanBarcode: _scanBarcode,
          ),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Pricing'),
          content: PricingStepContent(
            productPriceController: _productPriceController,
            rrpController: _rrpController,
            salePriceController: _salePriceController,
            isOnSale: _isOnSale,
            onIsOnSaleChanged: (value) {
              setState(() {
                _isOnSale = value ?? false;
              });
            },
          ),
          isActive: _currentStep >= 3,
          state: _currentStep > 3 ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Shipping Information'),
          content: ShippingInfoStepContent(
            selectedPackaging: _selectedPackaging,
            weightController: _weightController,
            weightUnit: _weightUnit,
            dimensionsControllerText: _dimensionsController.text,
            dimensionsUnit: _dimensionsUnit,
            onShowDimensionsDialog: _showDimensionsDialog,
            onPackagingChanged: (value) {
              setState(() {
                _selectedPackaging = value;
              });
            },
            onWeightUnitChanged: (value) {
              setState(() {
                _weightUnit = value;
              });
            },
          ),
          isActive: _currentStep >= 4,
          state: _currentStep > 4 ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Product Properties'),
          content: ProductPropertiesStepContent(
            selectedMaterial: _selectedMaterial,
            materials: _materials,
            colors: _colors,
            colorController: _colorController,
            onMaterialChanged: (value) {
              setState(() {
                _selectedMaterial = value;
              });
            },
            onAddMaterial: () {
              setState(() {
                if (_selectedMaterial != null &&
                    _selectedMaterial!.isNotEmpty &&
                    !_materials.contains(_selectedMaterial)) {
                  _materials.add(_selectedMaterial!);
                }
              });
            },
            onRemoveMaterial: (index) {
              setState(() {
                _materials.removeAt(index);
              });
            },
            onAddColor: () {
              setState(() {
                if (_colorController.text.isNotEmpty) {
                  _colors.add(_colorController.text);
                  _colorController.clear();
                }
              });
            },
            onRemoveColor: (index) {
              setState(() {
                _colors.removeAt(index);
              });
            },
          ),
          isActive: _currentStep >= 5,
          state: _currentStep > 5 ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Product Tags'),
          content: ProductTagsStepContent(
            tagController: _tagController,
            tags: _tags,
            onAddTag: () {
              setState(() {
                if (_tagController.text.isNotEmpty) {
                  _tags.add(_tagController.text);
                  _tagController.clear();
                }
              });
            },
            onRemoveTag: (index) {
              setState(() {
                _tags.removeAt(index);
              });
            },
          ),
          isActive: _currentStep >= 6,
          state: _currentStep > 6 ? StepState.complete : StepState.editing,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: const Color(0xFF31135F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: Stepper(
                      steps: _steps(),
                      currentStep: _currentStep,
                      onStepTapped: (step) {
                        if (!mounted) return;
                        setState(() {
                          _currentStep = step;
                        });
                      },
                      controlsBuilder:
                          (BuildContext context, ControlsDetails details) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Save Draft',
                              style: TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () => _saveProduct(isDraft: true),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _saveProduct(isDraft: false),
                          child: const Text('Save Product'),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            const Text(
                              'Reset Form',
                              style: TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _resetForm,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

List<String> _normalizeToListString(dynamic data) {
  if (data is List) {
    return List<String>.from(data.map((item) => item.toString()));
  } else if (data is String) {
    return [data];
  } else {
    return [];
  }
}
