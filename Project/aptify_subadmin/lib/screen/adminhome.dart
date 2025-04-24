import 'package:aptify_subadmin/screen/class.dart';
import 'package:aptify_subadmin/screen/faculty.dart';
import 'package:aptify_subadmin/screen/student.dart';
import 'package:flutter/material.dart';
import 'package:aptify_subadmin/components/appbar.dart';
import 'package:aptify_subadmin/components/sidebar.dart';
import 'package:aptify_subadmin/screen/dashboard.dart';
import 'package:aptify_subadmin/screen/year.dart';


class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
      const Dashboard(),
      const Faculty(),
      const Year(),
      const DepClass(),
      const StudentPage()
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
