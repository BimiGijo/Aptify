import 'package:aptify_admin/screen/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:aptify_admin/component/appbar.dart';
import 'package:aptify_admin/component/sidebar.dart';
import 'package:aptify_admin/screen/dashboard.dart';
import 'package:aptify_admin/screen/course.dart';
import 'package:aptify_admin/screen/category.dart';
import 'package:aptify_admin/screen/complaint.dart';
import 'package:aptify_admin/screen/feedback.dart';
import 'package:aptify_admin/screen/department.dart';
import 'package:aptify_admin/screen/subadmin.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0; // Default screen is Dashboard

  final List<Widget> _pages = [
    const Dashboard(),
    SubAdmin(),
    const Department(),
    const Course(),
    const Category(),
    const Difficulty(),
    const ComplaintScreen(),
    const FeedbackScreen(),
  ];

  void onSidebarItemTapped(int index) {
    if (index < _pages.length) { // Prevent out-of-bounds error
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFffffff),
      body: Row(
        children: [
          Expanded(
            flex: 2, // Adjust for better layout
            child: Sidebar(onItemSelected: onSidebarItemTapped),
          ),
          Expanded(
            flex: 7, // Adjust for better layout
            child: Column(
              children: [
                const Appbar(),
                Expanded(child: _pages[_selectedIndex]), // Directly show the page
              ],
            ),
          ),
        ],
      ),
    );
  }
}
