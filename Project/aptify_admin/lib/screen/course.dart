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
  int _editId = 0;

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
          .select('course_id, course_name, department_id, tbl_department!inner(department_name)');

      setState(() {
        _courseList = response.map<Map<String,dynamic>>((course) {
          return {
            'course_id' : course['course_id'],
            'course_name': course['course_name'],
            'department_name': course['tbl_department']['department_name'],
            'department_id': course['department_id']
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  Future<void> courseSubmit() async {
    try {
      final course = _courseController.text.trim().toLowerCase();
      if (selectedDept == null || course.isEmpty) {
        showSnackbar('Please enter course name and select department', Colors.red);
        return;
      }

      final courseName = await supabase
        .from('tbl_course')
        .select('course_name');

      final isDuplicate = courseName.any((c) =>
        c['course_name'].toString().trim().toLowerCase() == course );

      if (isDuplicate) {
        showSnackbar('Course with this name already exists', Colors.orange);
        return;
      }
      

      await supabase.from('tbl_course').insert({
        'department_id': selectedDept,
        'course_name': course,
      });

      await fetchCourses(); // Refresh list after adding
      
      
      setState(() {
        _isFormVisible = false;
        _courseController.clear();
        selectedDept=null;
      });
      showSnackbar('Course Added', Colors.green);
    } catch (e) {
      print('Error inserting course: $e');
    }
  }


  Future<void> deleteCourse(int id) async {
    try {
      await supabase.from('tbl_course')
      .delete()
      .eq('course_id', id);

      await fetchCourses();
      showSnackbar('Course Deleted', Colors.red);

      setState(() {
        if (_editId == id) {
          _editId = 0;
          _courseController.clear(); 
          selectedDept = null;
        }
      });
    } catch (e) {
      showSnackbar('Unexpected error occurred', Colors.red);
      print('Error deleting course: $e');
    }
  }

  Future<void> updateCourse() async {
    try {
      if(_courseController.text.trim().isEmpty || _editId == 0) return;

      await supabase.from('tbl_course').update({
        'course_name': _courseController.text.trim(),
        'department_id' : selectedDept,
      }).eq('course_id', _editId);

      await fetchCourses();
      showSnackbar("Course Updated", Colors.green);

      setState(() {
        _editId = 0;
        _courseController.clear();
        selectedDept = null;
        _isFormVisible = false;
      });
    } catch (e) {
      showSnackbar("Error updating course", Colors.red);
      print('Error updating course: $e');
    }
  }

  void populateFormForEdit(Map<String, dynamic> course) {
    setState(() {
      _editId = course['course_id'];
      _courseController.text = course['course_name'];
      selectedDept = course['department_id'].toString();
      _isFormVisible = true;
    });
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
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
              const Text('Manage Course',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF161616),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                    if (!_isFormVisible) {
                      _editId = 0;
                      _courseController.clear();
                      selectedDept = null;
                    }
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
                    padding: const EdgeInsets.all(16),
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
                        Text(_editId == 0 ? 'Add Course' : 'Update Course',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _courseController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Course Name"
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedDept,
                          hint: const Text("Select Department"),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
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
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF161616),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 70, vertical: 18),
                          ),
                          onPressed: _editId == 0 ? courseSubmit : updateCourse,
                          child: Text(_editId == 0 ? "Add" : "Update",
                              style: const TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: _courseList.isEmpty
                ? const Center(child: Text("No Courses Added"))
                : ListView.builder(
                    itemCount: _courseList.length,
                    itemBuilder: (context, index) {
                      final course = _courseList[index];
                      return Card(
                        child: ListTile(
                          title: Text(course['course_name']),
                          subtitle: Text('Department: ${course['department_name']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => populateFormForEdit(course),
                                icon: const Icon(Icons.edit, color: Colors.blue),
                              ),
                              IconButton(
                                onPressed: () => deleteCourse(course['course_id']),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              )
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
