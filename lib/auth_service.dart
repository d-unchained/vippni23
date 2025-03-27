// auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Expose the auth state changes stream
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
    String shopName,
    String shopAddress,
    String homeAddress,
    String postageType,
    List<String> productTypes,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        String vendorId = user.uid;

        await _firestore.collection('vendors').doc(vendorId).set({
          'fullName': fullName,
          'email': email,
          'shopName': shopName,
          'shopAddress': shopAddress,
          'homeAddress': homeAddress,
          'postageType': postageType,
          'productTypes': productTypes,
          'role': 'pending',
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException in signUpWithEmailPassword: ${e.message}');
      return null;
    } catch (e) {
      print('Error in signUpWithEmailPassword: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Get vendor role
  Future<String?> getVendorRole(String vendorId) async {
    try {
      DocumentSnapshot vendorDoc =
          await _firestore.collection('vendors').doc(vendorId).get();
      if (vendorDoc.exists) {
        return vendorDoc['role'];
      } else {
        print('Vendor document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching vendor role: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Update product
  Future<void> updateProduct(
    String productId,
    String productName,
    String productDescription,
    double productPrice,
    int productQuantity,
    String productType,
    String productAvailability,
    double weight,
    String weightUnit,
    double length,
    double width,
    double height,
    String dimensionUnit,
    String material,
    String envelopeSize,
    List<String> colors,
    List<String> tags,
    List<String> imageUrls,
  ) async {
    try {
      final productData = {
        'name': productName,
        'description': productDescription,
        'price': productPrice,
        'quantity': productQuantity,
        'type': productType,
        'availability': productAvailability,
        'weight': weight,
        'weightUnit': weightUnit,
        'length': length,
        'width': width,
        'height': height,
        'dimensionUnit': dimensionUnit,
        'material': material,
        'envelopeSize': envelopeSize,
        'colors': colors,
        'tags': tags,
        'images': imageUrls,
        'userId': _auth.currentUser!.uid,
      };

      await _firestore
          .collection('products')
          .doc(productId)
          .update(productData);
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  // Add product
  Future<void> addProduct(
    String productName,
    String productDescription,
    double productPrice,
    int productQuantity,
    String productType,
    String productAvailability,
    double weight,
    String weightUnit,
    double length,
    double width,
    double height,
    String dimensionUnit,
    String material,
    String envelopeSize,
    List<String> colors,
    List<String> tags,
    List<String> imageUrls,
  ) async {
    try {
      final productData = {
        'name': productName,
        'description': productDescription,
        'price': productPrice,
        'quantity': productQuantity,
        'type': productType,
        'availability': productAvailability,
        'weight': weight,
        'weightUnit': weightUnit,
        'length': length,
        'width': width,
        'height': height,
        'dimensionUnit': dimensionUnit,
        'material': material,
        'envelopeSize': envelopeSize,
        'colors': colors,
        'tags': tags,
        'images': imageUrls,
        'userId': _auth.currentUser!.uid,
      };

      await _firestore.collection('products').add(productData);
    } catch (e) {
      print('Error adding product: $e');
    }
  }
}
