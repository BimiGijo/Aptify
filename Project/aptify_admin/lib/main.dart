import 'package:aptify_admin/screen/adminhome.dart';
import 'package:flutter/material.dart';
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
      home: AdminHome(),
    );
  }
}
