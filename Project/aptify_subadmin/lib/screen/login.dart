import 'package:aptify_subadmin/main.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  Future<void> register () async {
    try {
      final auth = await supabase.auth.signUp(password: _passwordController.text, email: _emailController.text);
      String uid = auth.user!.id;
      storeData(uid);
    } catch (e) {
        print('Error Registering College $e'); 
    }
  }

  Future<void> storeData(String uid) async {
    try {
      String confirmPassword = _confirmController.text;
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      if (password == confirmPassword) {
        await supabase.from("tbl_subadmin").insert({
          'subadmin_id': uid,
          'subadmin_name': name,
          'subadmin_email': email,
          'subadmin_password': password
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('College Added Successfully')));
      } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password and Confirm Password are not same')) );
      }
    } catch (e) {
        print('ERROR Adding College $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text("Name"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text("Email"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 6),
              child: Text("Password"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 6),
              child: Text("Confirm Password"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:20, bottom: 6),
              child: ElevatedButton(
                onPressed: () { register(); }, child: Text('Add')),
            )
          ],
        ),
      ),
    );
  }
}
