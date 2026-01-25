import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DateFormatting for intl package
  await initializeDateFormatting('vi_VN');
  
  // Initialize Firebase only if not already initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized
    print('Firebase initialization: $e');
  }

  await Supabase.initialize(
    url: 'https://tyjrrphjrqkhdlupzxan.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5anJycGhqcnFraGRsdXB6eGFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNDM0ODksImV4cCI6MjA4NDcxOTQ4OX0.cwsCnGwBCmRuFanEJeVddeUbNEPeoIj7HSF1zRMwTQw',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainScreen();
          }

          // Chưa đăng nhập → Login
          return const LoginScreen();
        },
      ),
    );
  }
}
