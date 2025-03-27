// profile_menu.dart

import 'package:flutter/material.dart';
import '../profile_menu/change_language_screen.dart';
import '../profile_menu/terms_conditions_screen.dart';
import '../profile_menu/privacy_policy_screen.dart';
import '../profile_menu/contact_us_screen.dart';
import '../profile_menu/return_policy_screen.dart';
import '../profile_menu/shipping_policy_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF31135F),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF31135F)),
            title: const Text('Change Language'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangeLanguageScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule_folder_outlined,
                color: Color(0xFF31135F)),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TermsConditionsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined,
                color: Color(0xFF31135F)),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined,
                color: Color(0xFF31135F)),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ContactUsScreen()),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.swap_horiz_outlined, color: Color(0xFF31135F)),
            title: const Text('Return Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReturnPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined,
                color: Color(0xFF31135F)),
            title: const Text('Shipping Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ShippingPolicyScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF31135F)),
            title: const Text('Logout'),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // No need to navigate manually; AuthWrapper will handle the redirection
              } catch (e) {
                // Handle error, e.g., show a snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
