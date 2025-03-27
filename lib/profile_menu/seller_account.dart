import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:country_picker/country_picker.dart';

class SellerAccountScreen extends StatefulWidget {
  final User? user;

  const SellerAccountScreen({required this.user, super.key});

  @override
  SellerAccountScreenState createState() => SellerAccountScreenState();
}

class SellerAccountScreenState extends State<SellerAccountScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopCityController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _postageTypeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _secondaryContactController =
      TextEditingController();
  final List<String> _productTypes = [];
  String _selectedProductType = '';
  String _selectedPhoneCountryCode = '+61';
  String _selectedSecondaryPhoneCountryCode = '+61';
  final List<File> _taxDocuments = [];
  List<File> _shopPictures = [];
  List<File> _businessDocuments = [];
  List<File> _identityDocuments = [];
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _addressSuggestions = [];

  List<Step> _steps() => [
        Step(
          title: const Text('Verification'),
          content: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              _selectedPhoneCountryCode =
                                  '+${country.phoneCode}';
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _selectedPhoneCountryCode,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              _selectedSecondaryPhoneCountryCode =
                                  '+${country.phoneCode}';
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _selectedSecondaryPhoneCountryCode,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _secondaryContactController,
                      decoration: const InputDecoration(
                        labelText: 'Secondary Contact Number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'^\d{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  TextFormField(
                    controller: _homeAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Home Address *',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _textSearch(value, 'home');
                      } else {
                        setState(() {
                          _addressSuggestions = [];
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your home address';
                      }
                      return null;
                    },
                  ),
                  if (_addressSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 60.0),
                      constraints: const BoxConstraints(maxHeight: 200.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _addressSuggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_addressSuggestions[index]),
                            onTap: () {
                              _homeAddressController.text =
                                  _addressSuggestions[index];
                              setState(() {
                                _addressSuggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              ListTile(
                leading: Icon(
                  Icons.file_upload,
                  color: _identityDocuments.isNotEmpty ? Colors.green : null,
                ),
                title: const Text('Upload Identity Documents'),
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);
                  if (result != null) {
                    setState(() {
                      _identityDocuments =
                          result.paths.map((path) => File(path!)).toList();
                    });
                  }
                },
              ),
            ],
          ),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Shop Information'),
          content: Column(
            children: <Widget>[
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your shop name';
                  }
                  return null;
                },
              ),
              Stack(
                children: [
                  TextFormField(
                    controller: _shopAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Shop Address *',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _textSearch(value, 'shop');
                      } else {
                        setState(() {
                          _addressSuggestions = [];
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your shop address';
                      }
                      return null;
                    },
                  ),
                  if (_addressSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 60.0),
                      constraints: const BoxConstraints(maxHeight: 200.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _addressSuggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_addressSuggestions[index]),
                            onTap: () {
                              _shopAddressController.text =
                                  _addressSuggestions[index];
                              setState(() {
                                _addressSuggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              Stack(
                children: [
                  TextFormField(
                    controller: _shopCityController,
                    decoration: const InputDecoration(
                      labelText: 'Shop City *',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _textSearchCity(value);
                      } else {
                        setState(() {
                          _addressSuggestions = [];
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your shop city';
                      }
                      return null;
                    },
                  ),
                  if (_addressSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 60.0),
                      constraints: const BoxConstraints(maxHeight: 200.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _addressSuggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_addressSuggestions[index]),
                            onTap: () {
                              _shopCityController.text =
                                  _addressSuggestions[index];
                              setState(() {
                                _addressSuggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              ListTile(
                leading: Icon(
                  Icons.file_upload,
                  color: _businessDocuments.isNotEmpty ? Colors.green : null,
                ),
                title: const Text('Upload Business Documents'),
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);
                  if (result != null) {
                    setState(() {
                      _businessDocuments =
                          result.paths.map((path) => File(path!)).toList();
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo,
                  color: _shopPictures.isNotEmpty ? Colors.green : null,
                ),
                title: const Text('Upload Shop Pictures'),
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);
                  if (result != null) {
                    setState(() {
                      _shopPictures =
                          result.paths.map((path) => File(path!)).toList();
                    });
                  }
                },
              ),
            ],
          ),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.editing,
        ),
        Step(
          title: const Text('Postage and Product Types'),
          content: Column(
            children: <Widget>[
              TextFormField(
                controller: _postageTypeController,
                decoration: const InputDecoration(
                    labelText: 'Postage Type Available *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the postage type available';
                  }
                  return null;
                },
              ),
              Column(
                children: <Widget>[
                  ..._productTypes.map((type) => ListTile(
                        title: Text(type),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () {
                            setState(() {
                              _productTypes.remove(type);
                            });
                          },
                        ),
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Add Product Type'),
                          onChanged: (value) {
                            _selectedProductType = value;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setState(() {
                            if (_selectedProductType.isNotEmpty) {
                              _productTypes.add(_selectedProductType);
                              _selectedProductType = '';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.editing,
        ),
      ];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .update({
        'phoneNumber':
            '$_selectedPhoneCountryCode${_phoneNumberController.text}',
        'shopName': _shopNameController.text,
        'shopAddress':
            '${_shopAddressController.text}, ${_shopCityController.text}',
        'homeAddress': _homeAddressController.text,
        'postageType': _postageTypeController.text,
        'productTypes': _productTypes,
        'taxDocuments': [],
        'businessDocuments': [],
        'identityDocuments': [],
        'shopPictures': [],
      });

      await _uploadDocuments(widget.user!.uid);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  Future<void> _uploadDocuments(String userId) async {
    await _uploadFileList(_taxDocuments, userId, 'taxDocuments');
    await _uploadFileList(_businessDocuments, userId, 'businessDocuments');
    await _uploadFileList(_identityDocuments, userId, 'identityDocuments');
    await _uploadFileList(_shopPictures, userId, 'shopPictures');
  }

  Future<void> _uploadFileList(
      List<File> files, String userId, String folder) async {
    for (File file in files) {
      String fileName =
          '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        folder: FieldValue.arrayUnion([downloadUrl]),
      });
    }
  }

  Future<void> _textSearch(String queryValue, String type) async {
    const String apiKey = 'AIzaSyCyYaC1lpWX_nzuALrxUMXy7gWzdSiwtV0';
    const String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    final response = await http.get(
      Uri.parse('$url?input=$queryValue&key=$apiKey&components=country:au'),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final List<dynamic> predictions = result['predictions'];
      setState(() {
        _addressSuggestions =
            predictions.map((p) => p['description'] as String).toList();
      });
    } else {
      setState(() {
        _addressSuggestions = [];
      });
    }
  }

  Future<void> _textSearchCity(String queryValue) async {
    const String apiKey = 'AIzaSyCyYaC1lpWX_nzuALrxUMXy7gWzdSiwtV0';
    const String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    final response = await http.get(
      Uri.parse(
          '$url?input=$queryValue&types=(cities)&key=$apiKey&components=country:au'),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final List<dynamic> predictions = result['predictions'];
      setState(() {
        _addressSuggestions =
            predictions.map((p) => p['description'] as String).toList();
      });
    } else {
      setState(() {
        _addressSuggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Account Setup'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Stepper(
                    steps: _steps(),
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_formKey.currentState!.validate()) {
                        if (_currentStep < _steps().length - 1) {
                          setState(() {
                            _currentStep += 1;
                          });
                        }
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() {
                          _currentStep -= 1;
                        });
                      }
                    },
                    onStepTapped: (step) {
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
                const SizedBox(height: 100),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
