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
    "Manage Category",
    "Manage Department",
    "View Complaints",
    "View Feedback",
  ];

  final List<IconData> icons = [
    Icons.dashboard,
    Icons.category,
    Icons.account_tree,
    Icons.report,
    Icons.feedback
  ];

  @override
  Widget build(BuildContext context) {
    return Container(width: 50,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent, // Darker highlight
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      widget.onItemSelected(index);
                    },
                    leading: Icon(
                      icons[index], 
                      color: isSelected ? Colors.orangeAccent : Colors.white, // Highlight active icon
                    ),
                    title: Text(
                      pages[index],
                      style: TextStyle(
                        color: isSelected ? Colors.orangeAccent : Colors.white, // Highlight text
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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