import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sport_place/screens/login_screen.dart';
import 'package:sport_place/screens/register_screen.dart';
import 'package:sport_place/screens/main_screen.dart';
import 'package:sport_place/screens/admin_booking_screen.dart'; // tambahkan ini
import 'package:sport_place/screens/booking_screen.dart'; // opsional jika dipakai

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport Place',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(), // ✅ tambahkan ini
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/admin':
            (context) =>
                const AdminBookingScreen(), // ✅ opsional untuk navigasi admin
        // '/booking': (context) => const BookingScreen(), // jika digunakan secara eksplisit
      },
    );
  }
}
