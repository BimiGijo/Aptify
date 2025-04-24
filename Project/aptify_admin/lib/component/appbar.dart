import 'package:flutter/material.dart';
import 'package:aptify_admin/screen/login.dart';
import 'package:aptify_admin/screen/changepassword.dart';

class Appbar extends StatelessWidget {
  const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1f1f1f), Color(0xFF1e2a78)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(
              Icons.account_circle,
              color: Color(0xFFfca311),
              size: 28,
            ),
            const SizedBox(width: 10),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: PopupMenuButton<String>(
                tooltip: '',
                offset: const Offset(0, 50),
                onSelected: (value) async {
                  if (value == 'change_password') {
                    showDialog(
                      context: context,
                      builder: (context) => ChangePasswordDialog(),
                    );
                  } else if (value == 'logout') {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes', style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFF14213D),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_password',
                    child: Text('Change Password'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
