import 'package:flutter/material.dart';
import 'package:aptify_faculty/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  bool oldpasskey = true;
  bool newpasskey = true;
  bool conpasskey = true;

  final TextEditingController _oldpasswordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _conpasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> updatePassword() async {
    if (_newpasswordController.text != _conpasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirmation password do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verify the old password
      final response = await supabase.auth.signInWithPassword(
        email: supabase.auth.currentUser!.email!,
        password: _oldpasswordController.text,
      );

      if (response.user == null) {
        throw Exception('Current password is incorrect');
      }

      // Update the new password
      await supabase.auth.updateUser(
        UserAttributes(
          password: _newpasswordController.text.trim(),
        ),
      );

      // Update the password in the database
      await supabase
          .from('tbl_teacher')
          .update({
            'teacher_password': _newpasswordController.text.trim(),
          })
          .eq('teacher_id', supabase.auth.currentUser!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Clear the fields
      _oldpasswordController.clear();
      _newpasswordController.clear();
      _conpasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Change Password",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),

            // Old Password
            buildPasswordField(
              controller: _oldpasswordController,
              label: "Old Password",
              isObscure: oldpasskey,
              toggleVisibility: () => setState(() => oldpasskey = !oldpasskey),
            ),
            const SizedBox(height: 20),

            // New Password
            buildPasswordField(
              controller: _newpasswordController,
              label: "New Password",
              isObscure: newpasskey,
              toggleVisibility: () => setState(() => newpasskey = !newpasskey),
            ),
            const SizedBox(height: 20),

            // Confirm Password
            buildPasswordField(
              controller: _conpasswordController,
              label: "Confirm Password",
              isObscure: conpasskey,
              toggleVisibility: () => setState(() => conpasskey = !conpasskey),
            ),
            const SizedBox(height: 40),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Update Password",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable password field widget
  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
