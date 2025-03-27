import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShopInformationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;

  const ShopInformationScreen({required this.onNext, super.key});

  @override
  ShopInformationScreenState createState() => ShopInformationScreenState();
}

class ShopInformationScreenState extends State<ShopInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopCityController = TextEditingController();
  List<String> _addressSuggestions = [];

  Future<void> _textSearch(String queryValue) async {
    const String apiKey =
        'AIzaSyCyYaC1lpWX_nzuALrxUMXy7gWzdSiwtV0'; // Replace with your actual API key
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
    const String apiKey =
        'AIzaSyCyYaC1lpWX_nzuALrxUMXy7gWzdSiwtV0'; // Replace with your actual API key
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

  void _next() {
    if (_formKey.currentState!.validate()) {
      widget.onNext({
        'shopName': _shopNameController.text,
        'shopAddress': _shopAddressController.text,
        'shopCity': _shopCityController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                const SizedBox(height: 20),
                Stack(
                  children: [
                    TextFormField(
                      controller: _shopAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Shop Address *',
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _textSearch(value);
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _next,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
