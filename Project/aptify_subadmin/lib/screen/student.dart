import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _departmentList = [];
  List<Map<String, dynamic>> _courseList = [];
  List<Map<String, dynamic>> _studentList = [];
  List<Map<String, dynamic>> _filteredStudentList = [];

  String? _activeDepartmentId;
  String? _activeCourseId;

  @override
  void initState() {
    super.initState();
    fetchDepartment();
    fetchStudents();
    _searchController.addListener(_applySearch);
  }

  Future<void> fetchDepartment() async {
    try {
      final department = await supabase.from('tbl_department').select();
      setState(() {
        _departmentList = department;
      });
    } catch (e) {
      print("Error fetching department: $e");
    }
  }

  Future<void> fetchCourses(String departmentId) async {
    try {
      final courses = await supabase
          .from('tbl_course')
          .select()
          .eq('department_id', departmentId);
      setState(() {
        _courseList = courses;
      });
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  Future<void> fetchStudents() async {
    try {
      List<Map<String, dynamic>> students = [];
      final response = await supabase
          .from('tbl_student')
          .select('student_name, student_photo, class_id, tbl_class(course_id,tbl_teacher(college_id) tbl_course(course_id, course_name, department_id, tbl_department(department_id, department_name)))');
      for (var data in response) {
        if (data['tbl_class']['tbl_student']['college_id'] == supabase.auth.currentUser!.id) {
          students.add(data);
        }
      }
      print('Raw student data: $students');

      final formatted = students.map<Map<String, dynamic>>((s) {
        final classData = s['tbl_class'];
        final courseData = classData?['tbl_course'];
        final deptData = courseData?['tbl_department'];

        return {
          'student_name': s['student_name'],
          'student_photo': s['student_photo'],
          'class_id': s['class_id'],
          'course_id': courseData?['course_id'],
          'course_name': courseData?['course_name'] ?? 'Unknown',
          'department_id': courseData?['department_id'],
          'department_name': deptData?['department_name'] ?? 'Unknown',
        };
      }).toList();

      setState(() {
        _studentList = formatted;
        _filteredStudentList = formatted;
      });
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudentList = _studentList.where((s) {
        return s['student_name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _filterByDepartment(String? deptId) {
    if (_activeDepartmentId == deptId) {
      setState(() {
        _activeDepartmentId = null;
        _courseList = [];
        _activeCourseId = null;
        _filteredStudentList = _studentList;
      });
    } else {
      setState(() {
        _activeDepartmentId = deptId;
        _activeCourseId = null;
      });
      fetchCourses(deptId!);
      _filteredStudentList = _studentList
          .where((s) => s['department_id'].toString() == deptId)
          .toList();
    }
  }

  void _filterByCourse(String? courseId) {
    setState(() {
      _activeCourseId = courseId;
      _filteredStudentList = _studentList.where((s) {
        return s['department_id'].toString() == _activeDepartmentId &&
            s['course_id'].toString() == courseId;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("STUDENTS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: "Search by student name",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            children: _departmentList.map((dept) {
              final isSelected = _activeDepartmentId == dept['department_id'].toString();
              return ChoiceChip(
                label: Text(dept['department_name']),
                selected: isSelected,
                onSelected: (_) => _filterByDepartment(dept['department_id'].toString()),
              );
            }).toList(),
          ),
          if (_courseList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _courseList.map((course) {
                final isSelected = _activeCourseId == course['course_id'].toString();
                return ChoiceChip(
                  label: Text(course['course_name']),
                  selected: isSelected,
                  onSelected: (_) => _filterByCourse(course['course_id'].toString()),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 20),
          if (_filteredStudentList.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredStudentList.length,
              itemBuilder: (context, index) {
                final student = _filteredStudentList[index];
                return Card(
                  child: ListTile(
                    leading: student['student_photo'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(student['student_photo']),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student['student_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Department: ${student['department_name']}"),
                        Text("Course: ${student['course_name']}"),
                      ],
                    ),
                  ),
                );
              },
            )
          ] else
            const Center(child: Text("No students found."))
        ],
      ),
    );
  }
}
