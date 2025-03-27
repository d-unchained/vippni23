import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders_screen.dart';
import 'products_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart'; // Import the DashboardScreen
// Import ProductUploadScreen for add button
import 'auth_service.dart'; // Import the AuthService for role checking

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String userRole = 'pending'; // Default to 'pending'
  final AuthService _authService = AuthService();

  // Define the screens
  final List<Widget> _screens = [
    const ProfileScreen(),
    const ProductsScreen(),
    const OrdersScreen(),
    const DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getVendorRole(); // Fetch the vendor's role on screen initialization
  }

  Future<void> _getVendorRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? role = await _authService.getVendorRole(user.uid);
      if (role != null) {
        setState(() {
          userRole =
              role; // Set the user's role to either 'pending' or 'seller'
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior:
            Clip.none, // Allow the button to overflow above the nav bar
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (userRole == 'seller' || index == 0 || index == 3) {
                // Allow access to all screens for 'seller' or always allow 'Profile' and 'Notifications'
                setState(() {
                  _currentIndex = index;
                });
              } else {
                // If the user is 'pending', show a message for restricted access
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Your account is under review. Access restricted.'),
                  ),
                );
              }
            },
            selectedItemColor: const Color(0xFF31135F),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile', // Moved to the first option
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.inventory,
                  color: userRole == 'seller' ? null : Colors.grey,
                ),
                label: 'My Products', // Moved to second and renamed
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.monetization_on,
                  color: userRole == 'seller' ? null : Colors.grey,
                ),
                label: 'My Earnings', // Moved to third and renamed
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notifications', // Renamed to 'Notifications'
              ),
            ],
          ),
          // Position the Floating Action Button above the BottomNavigationBar
        ],
      ),
    );
  }
}
