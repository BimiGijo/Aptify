import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';

class Department extends StatefulWidget {
  const Department({super.key});

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> 
  with SingleTickerProviderStateMixin {
    bool _isFormVisible = false;
    final Duration _animationDuration = const Duration(microseconds: 300);
    final TextEditingController _departmentController = TextEditingController();

    List<Map<String,dynamic>> _department = [];

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> fetchDepartment() async {
    try {
      final department = _departmentController.text;
      await supabase.from('tbl_department').insert({'department' : department});
      
    } catch (e) {
        print('ERROR Inserting Department');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}