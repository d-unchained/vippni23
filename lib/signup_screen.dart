import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'terms_and_conditions.dart';
import 'profile_menu/privacy_policy.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  // Controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _postageTypeController = TextEditingController();
  final TextEditingController _productTypesController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _acceptTerms && _acceptPrivacy) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Collect product types as a list
        List<String> productTypes = _productTypesController.text
            .split(',')
            .map((e) => e.trim())
            .toList();

        User? user = await _auth.signUpWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _fullNameController.text.trim(),
          _shopNameController.text.trim(),
          _shopAddressController.text.trim(),
          _homeAddressController.text.trim(),
          _postageTypeController.text.trim(),
          productTypes,
        );

        setState(() {
          _isSubmitting = false;
        });

        if (!mounted) return;
        Navigator.of(context).pop(); // Dismiss the loading dialog

        if (user != null) {
          // Save the login session
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home', // Navigate to HomeScreen
              (route) => false,
            );
          }
        } else {
          _showErrorDialog('Failed to sign up. Please try again.');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        if (!mounted) return;
        Navigator.of(context).pop(); // Dismiss the loading dialog

        if (e.code == 'email-already-in-use') {
          _showErrorDialog(
              'The email address is already in use by another account.');
        } else if (e.code == 'weak-password') {
          _showErrorDialog('The password provided is too weak.');
        } else if (e.code == 'invalid-email') {
          _showErrorDialog('The email address is not valid.');
        } else {
          _showErrorDialog('Failed to sign up. Please try again.');
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        if (!mounted) return;
        Navigator.of(context).pop(); // Dismiss the loading dialog
        _showErrorDialog('An error occurred. Please try again.');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please complete all required fields and accept policies.'),
        ),
      );
    }
  }

  Future<void> _showTermsAndConditions() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => const TermsAndConditions(),
    );

    setState(() {
      _acceptTerms = result ?? false;
    });
  }

  Future<void> _showPrivacyPolicy() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => const PrivacyPolicy(),
    );

    setState(() {
      _acceptPrivacy = result ?? false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _fullNameController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _homeAddressController.dispose();
    _postageTypeController.dispose();
    _productTypesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Sign Up'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name *',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _shopNameController,
                        label: 'Shop Name *',
                        icon: Icons.store,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your shop name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _shopAddressController,
                        label: 'Shop Address *',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your shop address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _homeAddressController,
                        label: 'Home Address *',
                        icon: Icons.home,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your home address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _postageTypeController,
                        label: 'Postage Type *',
                        icon: Icons.local_shipping,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your postage type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _productTypesController,
                        label: 'Product Types (comma-separated) *',
                        icon: Icons.category,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your product types';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email *',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password *',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 8) {
                            return 'Please enter a password with at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password *',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildCheckBoxTile(
                        title: 'Accept Terms and Conditions *',
                        value: _acceptTerms,
                        onTap: _showTermsAndConditions,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                      _buildCheckBoxTile(
                        title: 'Accept Privacy Policies *',
                        value: _acceptPrivacy,
                        onTap: _showPrivacyPolicy,
                        onChanged: (value) {
                          setState(() {
                            _acceptPrivacy = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 80), // Space for the submit button
                    ],
                  ),
                ),
              ),
            ),
            // Submit Button Fixed at Bottom
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (_isSubmitting)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildCheckBoxTile({
    required String title,
    required bool value,
    required VoidCallback onTap,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.deepPurple,
          ),
        ),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.deepPurple,
    );
  }
}
