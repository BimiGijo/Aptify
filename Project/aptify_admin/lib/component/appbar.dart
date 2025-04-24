import 'package:aptify_admin/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:aptify_admin/screen/changepassword.dart';

class Appbar extends StatelessWidget {
  const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF14213D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.account_circle,
            color: Color(0xFFfca311),
          ),
          SizedBox(width: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: PopupMenuButton<String>(
              tooltip: '',
              offset: Offset(0, 50),
              onSelected: (value) async {
                if (value == 'change_password') {
                  // Handle Change Password
                  showDialog(context: context, builder: (context) => ChangePasswordDialog());
                } else if (value == 'logout') {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Confirm logout
                          },
                          child: Text('Yes', style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF14213D),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false); // Cancel logout
                          },
                          child: Text('No', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    // Optionally: Clear shared preferences here if used
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'change_password',
                  child: Text('Change Password'),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Text(
                  "Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}
