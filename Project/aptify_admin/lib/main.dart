
import 'package:aptify_admin/screen/adminhome.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aptify_admin/screen/login.dart';


Future<void> main() async {
   await Supabase.initialize(
    url: 'https://udwljnpnaiwtxapejhtk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkd2xqbnBuYWl3dHhhcGVqaHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzNDYzOTAsImV4cCI6MjA0OTkyMjM5MH0.ygLmDJT5qw0J33qVggZBfHFMBrSggGrCi5BDytpTC_8',
  );
  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state
    if (session != null) {
      return const AdminHome(); // Replace with your home screen widget
    } else {
      return const LoginPage(); // Replace with your auth page widget
    }
  }
}
