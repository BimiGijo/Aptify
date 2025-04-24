import 'package:flutter/material.dart';
import 'package:aptify_faculty/main.dart';

class MyStudent extends StatefulWidget {
  const MyStudent({super.key});

  @override
  State<MyStudent> createState() => _MyStudentState();
}

class _MyStudentState extends State<MyStudent> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // **Fetch Students from Database**
  Future<void> fetchStudents() async {
    final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception("Current teacher not found");
      }

      // Fetch class where teacher_id = currentUserId
      final classResponse = await supabase
          .from('tbl_class')
          .select('class_id')
          .eq('teacher_id', currentUserId)
          .limit(1)
          .maybeSingle();

      if (classResponse == null || classResponse['class_id'] == null) {
        throw Exception("Class not assigned to this teacher");
      }

      final classId = classResponse['class_id'];
    try {
      final List<Map<String, dynamic>> data = await supabase
          .from('tbl_student')
          .select()
          .eq('class_id', classId);

      setState(() {
        students = data;
      });
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Students List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(student);
              },
            ),
    );
  }

  // **Student Card Widget**
  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[900],
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          student['student_name'] ?? 'Unknown',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📧 ${student['student_email']}"),
            Text("📞 ${student['student_contact']}"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteStudent(student['student_id']),
        ),
      ),
    );
  }

  // **Delete Student Function**
  Future<void> _deleteStudent(String studentId) async {
    try {
      await supabase
          .from('tbl_student')
          .delete()
          .eq('student_id', studentId);

      setState(() {
        students.removeWhere((student) => student['student_id'] == studentId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error deleting student: $e');
    }
  }
}
