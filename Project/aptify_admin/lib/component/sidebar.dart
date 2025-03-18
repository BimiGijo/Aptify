import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(int) onItemSelected;
  const Sidebar({super.key, required this.onItemSelected});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0; // Track selected item

  final List<String> pages = [
    "Dashboard",
    "Manage Colleges",
    "Manage Department",
    "Manage Courses",
    "Manage Category",
    "Manage Difficulty",
    "View Complaints",
    "View Feedback",
  ];

  final List<IconData> icons = [
    Icons.dashboard,
    Icons.school,
    Icons.account_tree,
    Icons.category,
    Icons.school,
    Icons.category,
    Icons.report,
    Icons.feedback
  ];

  @override
  Widget build(BuildContext context) {
    return Container(  
      width: 100, 
      constraints: const BoxConstraints(maxWidth: 100), 
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF0A192F)], // Darker gradient
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(221, 49, 49, 49), // Stronger shadow for better separation
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 70),
          Expanded(
            child: ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      widget.onItemSelected(index);
                    },
                    leading: Icon(
                      icons[index], 
                      color: isSelected ? Colors.orangeAccent : Colors.white,
                      size: 30, 
                    ),
                    title: Text(
                      pages[index],
                      style: TextStyle(
                        color: isSelected ? Colors.orangeAccent : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16, 
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
