import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';

class DepClass extends StatefulWidget {
  const DepClass({super.key});

  @override
  State<DepClass> createState() => _DepClassState();
}

class _DepClassState extends State<DepClass> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  bool _isEditMode = false;
  int? _editingClassId;

  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _classController = TextEditingController();

  List<Map<String, dynamic>> _classList = [];
  List<Map<String, dynamic>> _courseList = [];
  List<Map<String, dynamic>> _yearList = [];
  List<Map<String, dynamic>> _teacherList = [];
  List<Map<String, dynamic>> _departmentList = [];

  String? selectedCourse;
  String? selectedYear;
  String? selectedTeacher;
  String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    fetchDepartment();
    fetchYear();
    fetchClass();
  }

  Future<void> fetchDepartment() async {
    try {
      final department = await supabase.from('tbl_department').select();
      setState(() {
        _departmentList = department;
      });
    } catch (e) {
      print('Error Fetching Department: $e');
    }
  }

  Future<void> fetchCourses(String id) async {
    try {
      final course = await supabase.from('tbl_course').select().eq('department_id', id);
      setState(() {
        _courseList = course;
      });
    } catch (e) {
      print('Error Fetching Courses: $e');
    }
  }

  Future<void> fetchYear() async {
    try {
      final year = await supabase.from('tbl_year').select();
      setState(() {
        _yearList = year;
      });
    } catch (e) {
      print('Error Fetching Year: $e');
    }
  }

  Future<void> fetchTeacher(String id) async {
    if (id.isEmpty) return;
    try {
      final teacher = await supabase.from('tbl_teacher').select().eq('department_id', id);
      setState(() {
        _teacherList = teacher;
      });
    } catch (e) {
      print('Error Fetching Teacher: $e');
    }
  }

  Future<void> fetchClass() async {
    try {
      final response = await supabase
          .from('tbl_class')
          .select("*, tbl_course(*,tbl_department(*)),tbl_year(*),tbl_teacher(*)");

      setState(() {
        _classList = response.map<Map<String, dynamic>>((classes) {
          return {
            'class_id': classes['class_id'],
            'class_name': classes['class_name'] ?? 'N/A',
            'department_id': classes['tbl_course']['tbl_department']['department_id'],
            'department_name': classes['tbl_course']['tbl_department']['department_name'] ?? 'N/A',
            'course_id': classes['tbl_course']['course_id'],
            'course_name': classes['tbl_course']['course_name'] ?? 'N/A',
            'teacher_id': classes['tbl_teacher']['teacher_id'],
            'teacher_name': classes['tbl_teacher']['teacher_name'] ?? 'N/A',
            'year_id': classes['tbl_year']['year_id'],
            'year_name': classes['tbl_year']['year_name'] ?? 'N/A',
          };
        }).toList();
      });
    } catch (e) {
      print('Error Fetching Class: $e');
    }
  }

  Future<void> classSubmit() async {
    try {
      final classes = _classController.text.trim();
      if (selectedCourse == null ||
          selectedTeacher == null ||
          selectedYear == null ||
          selectedDepartment == null ||
          classes.isEmpty) {
        showSnackbar('Please fill all the details', Colors.red);
        return;
      }

      if (_isEditMode && _editingClassId != null) {
        await supabase
            .from('tbl_class')
            .update({'teacher_id': selectedTeacher})
            .eq('class_id', _editingClassId!);
        showSnackbar('Class Updated', Colors.green);
      } else {
        await supabase.from('tbl_class').insert({
          'course_id': selectedCourse,
          'year_id': selectedYear,
          'teacher_id': selectedTeacher,
          'class_name': classes
        });
        showSnackbar('Class Added', Colors.green);
      }

      fetchClass();
      _classController.clear();
      setState(() {
        _isFormVisible = false;
        _isEditMode = false;
        _editingClassId = null;
        selectedDepartment = null;
        selectedCourse = null;
        selectedTeacher = null;
        selectedYear = null;
        _courseList = [];
        _teacherList = [];
      });
    } catch (e) {
      print('Error Saving Class: $e');
      showSnackbar('Failed to save class.', Colors.red);
    }
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161616),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                    _isEditMode = false;
                    _editingClassId = null;
                    _classController.clear();
                    selectedDepartment = null;
                    selectedCourse = null;
                    selectedTeacher = null;
                    selectedYear = null;
                    _courseList = [];
                    _teacherList = [];
                  });
                },
                label: Text(_isFormVisible ? "Cancel" : "Add", style: const TextStyle(color: Colors.white)),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add, color: Colors.white),
              ),
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String?>(
                          value: selectedDepartment,
                          hint: const Text('Select Department'),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: _departmentList.map((department) {
                            return DropdownMenuItem<String?>(
                              value: department['department_id'].toString(),
                              child: Text(department['department_name']),
                            );
                          }).toList(),
                          onChanged: null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String?>(
                          value: selectedCourse,
                          hint: const Text('Select Course'),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: _courseList.map((course) {
                            return DropdownMenuItem<String?>(
                              value: course['course_id'].toString(),
                              child: Text(course['course_name']),
                            );
                          }).toList(),
                          onChanged: null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String?>(
                          value: selectedYear,
                          hint: const Text('Select Academic Year'),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: _yearList.map((year) {
                            return DropdownMenuItem<String?>(
                              value: year['year_id'].toString(),
                              child: Text(year['year_name']),
                            );
                          }).toList(),
                          onChanged: null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String?>(
                          value: selectedTeacher,
                          hint: const Text('Select Teacher'),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: _teacherList.map((teacher) {
                            return DropdownMenuItem<String?>(
                              value: teacher['teacher_id'].toString(),
                              child: Text(teacher['teacher_name']),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedTeacher = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _classController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "Class Name"),
                          enabled: false,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF161616),
                            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 18),
                          ),
                          onPressed: classSubmit,
                          child: Text(_isEditMode ? 'Update' : 'Add', style: const TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  )
                : Container(),
          ),
          const SizedBox(height: 30),
          const Text("CLASSES", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DataTable(
            columns: const [
              DataColumn(label: Text('Sl No')),
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Course')),
              DataColumn(label: Text('Teacher')),
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Action')),
            ],
            rows: _classList.asMap().entries.map((entry) {
              final row = entry.value;
              return DataRow(cells: [
                DataCell(Text((entry.key + 1).toString())),
                DataCell(Text(row['class_name'])),
                DataCell(Text(row['department_name'])),
                DataCell(Text(row['course_name'])),
                DataCell(Text(row['teacher_name'])),
                DataCell(Text(row['year_name'])),
                DataCell(
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161616),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _isFormVisible = true;
                        _isEditMode = true;
                        _editingClassId = row['class_id'];
                        _classController.text = row['class_name'];
                        selectedDepartment = row['department_id'].toString();
                        selectedCourse = row['course_id'].toString();
                        selectedYear = row['year_id'].toString();
                        selectedTeacher = row['teacher_id'].toString();
                      });
                      fetchCourses(row['department_id'].toString());
                      fetchTeacher(row['department_id'].toString());
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),

                ),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }
}