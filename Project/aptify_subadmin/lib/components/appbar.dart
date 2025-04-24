import 'package:aptify_subadmin/main.dart';
import 'package:flutter/material.dart';
import 'package:aptify_subadmin/screen/login.dart';
import 'package:aptify_subadmin/screen/changepassword.dart';


class Appbar extends StatefulWidget {
  const Appbar({super.key});

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {

  String collegeName = '';

  Future<void> fetchClg() async {
    try {
      final response = await supabase
          .from('tbl_subadmin')
          .select('subadmin_name')
          .eq('subadmin_id', supabase.auth.currentUser!.id)
          .single();
          setState(() {
            collegeName = response['subadmin_name'] ?? 'College Name';
          });
    } catch (e) {
      print("Error fetching college: $e");
      
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchClg();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color.fromARGB(255, 1, 51, 105)], // Updated gradient to match screenshot
          begin: Alignment.centerLeft,
          end: Alignment.centerRight
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.account_circle,
            color: Colors.white,
          ),

          const SizedBox(width: 10),

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: PopupMenuButton<String> (
              tooltip: '',
              offset: const Offset(0, 50),
              onSelected: (value) async {
                if (value == 'change_password') {
                  // Handle Change Password
                  showDialog(context: context, builder: (context) => const ChangePasswordDialog());
                } else if (value == 'logout') {
                  final shouldLogout = await showDialog<bool> (
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); //Confirm Logout
                        },
                        child: const Text('Yes', style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF14213D)
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false); //Cancel Logout
                          }, child: const Text('No', style: TextStyle(color: Colors.white))
                          ),
                      ],
                    ));

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
                const PopupMenuItem(
                  value: 'change_password',
                  child: Text('Change Password')
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Text(collegeName,
                  style: const TextStyle(color:  Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline
                  )
                ),
              ),
            )
          ),

          const SizedBox(
            width: 40,
          )
        ],
      ),
    );
  }
}
