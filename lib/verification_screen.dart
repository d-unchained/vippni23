import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;

class VerificationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  const VerificationScreen({super.key, required this.onNext, User? user});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _secondaryContactController =
      TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  String _selectedPhoneCountryCode = '+61';
  String _selectedSecondaryPhoneCountryCode = '+61';
  List<String> _addressSuggestions = [];

  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 25)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller);
  }

  Future<void> _textSearch(String queryValue) async {
    const String apiKey = 'YOUR_GOOGLE_API_KEY'; // Add your Google API Key here
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

  void _validateAndNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext({
        'phoneNumber':
            '$_selectedPhoneCountryCode${_phoneNumberController.text}',
        'secondaryContact':
            '$_selectedSecondaryPhoneCountryCode${_secondaryContactController.text}',
        'homeAddress': _homeAddressController.text,
      });
    } else {
      _controller.forward().then((value) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                Stack(
                  children: [
                    TextFormField(
                      controller: _homeAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Home Address *',
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _validateAndNext,
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
