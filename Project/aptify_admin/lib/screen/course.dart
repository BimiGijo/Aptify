import 'package:aptify_admin/main.dart';
import 'package:flutter/material.dart';

class Course extends StatefulWidget {
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _courseController = TextEditingController();

  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> _courseList = [];
  String? selectedDept;

  @override
  void initState() {
    super.initState();
    fetchDepartment();
    fetchCourses();
  }

  Future<void> fetchDepartment() async {
    try {
      final response = await supabase.from('tbl_department').select();
      setState(() {
        departments = response;
      });
    } catch (e) {
      print("Error fetching department: $e");
    }
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase
          .from('tbl_course')
          .select('course_name, department_id, tbl_department!inner(department_name)');

      setState(() {
        _courseList = response.map((course) {
          return {
            'course_name': course['course_name'],
            'department_name': course['tbl_department']['department_name'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  Future<void> courseSubmit() async {
    try {
      final course = _courseController.text.trim();
      if (selectedDept == null || course.isEmpty) {
        showSnackbar('Please enter course name and select department', Colors.red);
        return;
      }

      await supabase.from('tbl_course').insert({
        'department_id': selectedDept,
        'course_name': course,
      });

      fetchCourses(); // Refresh list after adding
      _courseController.clear();
      
      setState(() {
        _isFormVisible = false;
        selectedDept=null;
      });
      showSnackbar('Course Added', Colors.green);
    } catch (e) {
      print('Error inserting course: $e');
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
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
              Text('Manage Course',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF161616),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                  });
                },
                label: Text(
                  _isFormVisible ? "Cancel" : "Add",
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  _isFormVisible ? Icons.cancel : Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text('Add Course',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _courseController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedDept,
                          hint: const Text("Select Department"),
                          onChanged: (newValue) {
                            setState(() {
                              selectedDept = newValue;
                            });
                          },
                          items: departments.map((department) {
                            return DropdownMenuItem<String>(
                              value: department['department_id'].toString(),
                              child: Text(department['department_name']),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF161616),
                            padding: EdgeInsets.symmetric(
                                horizontal: 70, vertical: 18),
                          ),
                          onPressed: courseSubmit,
                          child: Text("Add",
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: _courseList.isEmpty
                ? Center(child: Text("No Courses Added"))
                : ListView.builder(
                    itemCount: _courseList.length,
                    itemBuilder: (context, index) {
                      final course = _courseList[index];
                      return Card(
                        child: ListTile(
                          title: Text(course['course_name']),
                          subtitle: Text('Department: ${course['department_name']}'),
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
