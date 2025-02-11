import 'package:aptify_admin/main.dart';
import 'package:flutter/material.dart';

class Department extends StatefulWidget {
  const Department({super.key});

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  final TextEditingController _departmentController = TextEditingController();
  int editId = 0;

  Future<void> departmentSubmit() async {
    try {
      final department = _departmentController.text;
      await supabase.from('tbl_department').insert({
        'department' : department}
      );
      _departmentController.clear();
      departmentFetch();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Department Added')));
    } catch (e) {
      print('Error Submitting Department $e');
    }
  }

  List<Map<String,dynamic>>departmentList = [];

  Future<void> departmentFetch() async {
    try {
      final response = await supabase.from('tbl_department').select();
      if(response.isNotEmpty) {
        setState(() {
          departmentList = response;
        });
      }
    } catch (e) {
        print('Error Fetching Department $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_department').delete().eq('department_id', id);
      departmentFetch();
    } catch (e) {
      print('Error Deleting Data $e');
    }
  }

  Future<void> departmentUpdate() async {
    try {
      await supabase.from('tbl_department').update({'department' : _departmentController.text}).eq('department_id', editId);
      departmentFetch();
      setState(() {
        editId = 0;
      });
      _departmentController.clear();
    } catch (e) {
      print('Error Editing Department');
    }
  }

  @override
  void initState() {
    super.initState();
    departmentFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 6),
              child: Text("Department"),
            ),
          Padding(
              padding: const EdgeInsets.only(
                left: 40, right: 40, top: 20, bottom: 20),
            child: TextFormField(
              controller: _departmentController,
              decoration: InputDecoration(
                border: OutlineInputBorder()
              ),
            )
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
                top: 20
              ),
              child:
               ElevatedButton(
                onPressed: () {
                  if(editId == 0) {
                    departmentSubmit();
                  } else{
                    departmentUpdate();
                  }
                }, child: Text('Add')
            )
            ),

            SizedBox(
              height: 20,
            ),

            ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: departmentList.length,
              shrinkWrap: true,
              itemBuilder: (context,index) {
                final department = departmentList[index];
                return ListTile(
                  leading: Text((index+1).toString()),
                  title: Text(department['department']),
              trailing: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                      delete(department['department_id']);
                    }, icon: Icon(Icons.delete_outline, color: Colors.red,)),

                    IconButton(onPressed: () {
                      setState(() {
                        _departmentController.text = department['department'];
                        editId = department['department_id'];
                      });
                    } , icon: Icon(Icons.edit))
                  ],
                ),
              ),
                ); 
              }
            )
        ],
      ),
    );
  }
}