import 'package:aptify_faculty/screen/adminhome.dart';
import 'package:flutter/material.dart';
import 'package:aptify_faculty/screen/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
   await Supabase.initialize(
    url: 'https://udwljnpnaiwtxapejhtk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkd2xqbnBuYWl3dHhhcGVqaHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzNDYzOTAsImV4cCI6MjA0OTkyMjM5MH0.ygLmDJT5qw0J33qVggZBfHFMBrSggGrCi5BDytpTC_8',
  );
  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {        
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Faculty Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state
    if (session != null) {
      return FacultyHomePage(); // Replace with your home screen widget
    } else {
      return const LoginScreen(); // Replace with your auth page widget
    }
  }
}

