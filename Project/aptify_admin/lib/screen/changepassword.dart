import 'package:flutter/material.dart';
import 'package:aptify_admin/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
  

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key:key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _oldPassObscure = true;
  bool _newPassObscure = true;
  bool _confirmPassObscure = true;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New and confirm passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: supabase.auth.currentUser!.email!,
        password: _oldPasswordController.text,
      );

      if (response.user == null) {
        throw Exception('Current password is incorrect');
      }

      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      await supabase
          .from('tbl_admin')
          .update({'admin_password': _newPasswordController.text.trim()})
          .eq('admin_id', supabase.auth.currentUser!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully'), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPasswordField(
                controller: _oldPasswordController,
                label: "Old Password",
                obscure: _oldPassObscure,
                toggle: () => setState(() => _oldPassObscure = !_oldPassObscure),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _newPasswordController,
                label: "New Password",
                obscure: _newPassObscure,
                toggle: () => setState(() => _newPassObscure = !_newPassObscure),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                obscure: _confirmPassObscure,
                toggle: () => setState(() => _confirmPassObscure = !_confirmPassObscure),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF14213D)),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Update', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
    );
  }
}
