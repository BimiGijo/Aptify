import 'package:flutter/material.dart';
import 'package:aptify_admin/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Department extends StatefulWidget {
  const Department({Key? key}) : super(key:key);

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _departmentController = TextEditingController();
  List<Map<String, dynamic>> _departmentList = [];
  int _editId = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> departmentSubmit() async {
    try {
      String department = _departmentController.text.trim().toLowerCase();
      if (department.isEmpty) return;

      final departmentName = await supabase
        .from('tbl_department')
        .select('department_name');

      final isDuplicate = departmentName.any((c) =>
        c['department_name'].toString().trim().toLowerCase() == department);

      if (isDuplicate) {
        showSnackbar('Department already exists', Colors.orange);
        return;
      }

      await supabase
          .from('tbl_department')
          .insert({'department_name': department});

      await fetchData();

      setState(() {
        _isFormVisible = false;
        _departmentController.clear();
      });
      showSnackbar('Department Added', Colors.green);
    } catch (e) {
      print('Error inserting department: $e');
    }

  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_department').select();
      setState(() {
        _departmentList = response;
      });
    } catch (e) {
      print("Error fetching department: $e");
    }
  }

  Future<void> updateDepartment() async {
    try {
      if (_departmentController.text.trim().isEmpty || _editId == 0) return;

      await supabase.from('tbl_department').update({
        'department_name': _departmentController.text.trim(),
      }).eq('department_id', _editId);

      await fetchData();
      showSnackbar('Department Updated', Colors.green);

      setState(() {
        _editId = 0;
        _departmentController.clear();
        _isFormVisible = false;
      });
    } catch (e) {
      print("Error updating department: $e");
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      await supabase.from('tbl_department')
      .delete()
      .eq('department_id', id);

      await fetchData();
      showSnackbar('Department Deleted', Colors.red);

      setState(() {
        if (_editId == id) {
          _editId = 0;
          _departmentController.clear();
        }
      });
    } catch (e) {
      if (e is PostgrestException) {
      if (e.code == '23503') {
        showSnackbar('Cannot delete: This department is being used elsewhere.', Colors.red);
      } else {
        showSnackbar('Error: ${e.message}', Colors.red);
      }
    } else {
      showSnackbar('Unexpected error occurred', Colors.red);
    }
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color),
    );
  }

  void populateFormForEdit(Map<String, dynamic> department) {
    setState(() {
      _editId = department['department_id'];
      _departmentController.text = department['department_name'];
      _isFormVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MANAGE DEPARTMENT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161616),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding:
                       const EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                    if (!_isFormVisible) {
                      _editId = 0;
                      _departmentController.clear();
                    }
                  });
                },
                label: Text(_isFormVisible ? "Cancel" : "Add",
                    style: TextStyle(color: Colors.white)),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add,
                    color: Colors.white),
              )
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                            _editId == 0 ? "Add Department" : "Update Department",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF161616),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 18)),
                          onPressed: _editId == 0
                              ? departmentSubmit
                              : updateDepartment,
                          child: Text(_editId == 0 ? 'Add' : 'Update',
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: _departmentList.isEmpty
                ? Center(child: Text("No Department Found"))
                : ListView.builder(
                    itemCount: _departmentList.length,
                    itemBuilder: (context, index) {
                      final department = _departmentList[index];
                      return Card(
                        child: ListTile(
                          title: Text(department['department_name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    _editId = department['department_id'];
                                    _departmentController.text =
                                        department['department_name'];
                                    _isFormVisible = true;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteDepartment(
                                    department['department_id']),
                              ),
                            ],
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
