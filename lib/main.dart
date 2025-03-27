// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vipnni/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'product_upload_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'forgot_password.dart';
import 'home_screen.dart';
import 'profile_menu/seller_account.dart';
import 'splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      await _requestPermission();
      String? token = await _messaging.getToken();
      User? user = _auth.currentUser;
      if (token != null && user != null) {
        await _firestore
            .collection('vendors')
            .doc(user.uid)
            .update({'fcmToken': token});
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (!mounted) return;
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.notification!.title ?? 'New Notification'),
            ),
          );

          // Store notification in Firestore
          try {
            final User? user = _auth.currentUser;
            if (user != null) {
              await _firestore
                  .collection('vendors')
                  .doc(user.uid)
                  .collection('notifications')
                  .add({
                'title': message.notification!.title ?? 'No Title',
                'body': message.notification!.body ?? 'No Content',
                'timestamp': FieldValue.serverTimestamp(),
              });
            }
          } catch (e) {
            print('Error storing notification: $e');
          }
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle notification tap if needed
      });
    } catch (e) {
      // Handle errors silently or log them
      print('FCM Initialization Error: $e');
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      // Handle permission denial if necessary
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vipnni Seller',
      theme: ThemeData(
        primaryColor: const Color(0xFF31135F),
        hintColor: const Color(0xFFFFB23D),
        scaffoldBackgroundColor: const Color(0xFFD6F7FA),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF4ABDFF),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B29D1),
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF31135F),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup_step': (context) => const SignUpScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/upload': (context) => const ProductUploadScreen(),
        '/products': (context) => const ProductsScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/seller': (context) => const SellerAccountScreen(
              user: null,
            ),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _updateFCMToken(user.uid);
      }
    });
    _initializeFCMTokenForExistingUser();
  }

  Future<void> _updateFCMToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('vendors').doc(userId).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _initializeFCMTokenForExistingUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _updateFCMToken(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}




//AIzaSyCyYaC1lpWX_nzuALrxUMXy7gWzdSiwtV0

//31135F
//6B29D1
//4ABDFF
//D6F7FA
//FFB23D