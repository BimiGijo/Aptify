import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

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
          .from('tbl_subadmin')
          .update({'subadmin_password': _newPasswordController.text.trim()})
          .eq('subadmin_id', supabase.auth.currentUser!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully'), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop(); // Close the dialog
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}