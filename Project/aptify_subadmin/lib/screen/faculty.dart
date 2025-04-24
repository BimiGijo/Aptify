import 'dart:typed_data';
import 'package:aptify_subadmin/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';

class Faculty extends StatefulWidget {
  const Faculty({super.key});

  @override
  State<Faculty> createState() => _FacultyState();
}

class _FacultyState extends State<Faculty> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  PlatformFile? pickedImage;
  List<Map<String, dynamic>> _departmentList = [];
  String? selectedDepartment;
  String? _activeDepartmentId;
  List<Map<String, dynamic>> _teacherList = [];
  List<Map<String, dynamic>> _filteredTeacherList = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchDepartment();
    fetchAllTeachers();
    _searchController.addListener(_applySearch);
    _authService.printValue();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> fetchAllTeachers() async {
    try {
      print("Sub admin: ${supabase.auth.currentUser!.id}");
      final teachers = await supabase.from('tbl_teacher').select().eq('college_id', supabase.auth.currentUser!.id);
      print("Teachers: $teachers");
      setState(() {
        _teacherList = teachers;
        _filteredTeacherList = teachers;
        _activeDepartmentId = null;
      });
    } catch (e) {
      print("Error fetching all teachers: $e");
    }
  }

  Future<void> fetchTeachersByDepartment(String departmentId) async {
    try {
      final teachers = await supabase
          .from('tbl_teacher')
          .select()
          .eq('department_id', departmentId);

      setState(() {
        _teacherList = teachers;
        _filteredTeacherList = teachers;
      });

      _applySearch();
    } catch (e) {
      print("Error fetching teachers by department: $e");
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredTeacherList = _teacherList;
      } else {
        _filteredTeacherList = _teacherList.where((teacher) {
          final name = teacher['teacher_name']?.toLowerCase() ?? '';
          final email = teacher['teacher_email']?.toLowerCase() ?? '';
          return name.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<void> register() async {
    try {
      final auth = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final uid = auth.user!.id;
      await _authService.relogin();
      if (uid.isNotEmpty) {
        submitForm(uid);
      }
    } catch (e) {
      print("Authentication Error: $e");
    }
  }

  Future<void> submitForm(String uid) async {
    try {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String contact = _contactController.text.trim();
      String? url = await photoUpload(uid);

      if (selectedDepartment == null) {
        showSnackbar("Please select a department", Colors.red);
        return;
      }

      final emailName = await supabase.from('tbl_teacher').select('teacher_email');
      final isDuplicate = emailName.any((c) =>
          c['teacher_email'].toString().trim().toLowerCase() == email.toLowerCase());

      if (isDuplicate) {
        showSnackbar("Teacher Details Already Exists", Colors.orange);
        return;
      }

      if (url != null) {
        await supabase.from('tbl_teacher').insert({
          'teacher_id': uid,
          'department_id': selectedDepartment,
          'teacher_name': name,
          'teacher_contact': contact,
          'teacher_email': email,
          'teacher_password': password,
          'teacher_photo': url
        });
        fetchAllTeachers();
        showSnackbar("Teacher Details Added", Colors.green);

        setState(() {
          pickedImage = null;
          selectedDepartment = null;
          _nameController.clear();
          _passwordController.clear();
          _emailController.clear();
          _contactController.clear();
        });

        if (_activeDepartmentId == selectedDepartment) {
          fetchTeachersByDepartment(_activeDepartmentId!);
        } else {
          fetchAllTeachers();
        }

      } else {
        print("Teacher profile not given");
      }
    } catch (e) {
      print("Error Inserting Teacher Details: $e");
    }
  }

  Future<String?> photoUpload(String uid) async {
    if (pickedImage == null) return null;
    try {
      final bucketName = 'teacher';
      final filePath = "$uid-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
        filePath,
        pickedImage!.bytes!,
      );
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print("Error Uploading photo: $e");
      return null;
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

  void _onDepartmentTap(String deptId) {
    if (_activeDepartmentId == deptId) {
      fetchAllTeachers();
    } else {
      setState(() {
        _activeDepartmentId = deptId;
      });
      fetchTeachersByDepartment(deptId);
    }
  }

  Future<void> deleteTeacher(String teacherId) async {
    try {
      await supabase.from('tbl_teacher').delete().eq('teacher_id', teacherId);
      showSnackbar("Teacher deleted successfully", Colors.green);

      if (_activeDepartmentId != null) {
        fetchTeachersByDepartment(_activeDepartmentId!);
      } else {
        fetchAllTeachers();
      }
    } catch (e) {
      print("Error deleting teacher: $e");
      showSnackbar("Failed to delete teacher", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "FACULTY MEMBERS",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161616),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                  });
                },
                label: Text(_isFormVisible ? "Cancel" : "Add", style: const TextStyle(color: Colors.white)),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: "Search by name or email",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _departmentList.map((dept) {
              final String deptId = dept['department_id'].toString();
              final bool isSelected = _activeDepartmentId == deptId;

              return ChoiceChip(
                label: Text(dept['department_name']),
                selected: isSelected,
                onSelected: (_) => _onDepartmentTap(deptId),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          if (_filteredTeacherList.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTeacherList.length,
              itemBuilder: (context, index) {
                final teacher = _filteredTeacherList[index];
                final deptName = _departmentList
                    .firstWhere((dept) => dept['department_id'] == teacher['department_id'],
                        orElse: () => {'department_name': 'Unknown'})['department_name'];

                return Card(
                  child: ListTile(
                    leading: teacher['teacher_photo'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(teacher['teacher_photo']),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(teacher['teacher_name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher['teacher_email'] ?? ''),
                        Text('Contact: ${teacher['teacher_contact'] ?? ''}'),
                        Text('Department: $deptName'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteTeacher(teacher['teacher_id']),
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            const Center(child: Text("No faculty found.")),
          ],

          const SizedBox(height: 20),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? _buildForm()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 246, 243, 243).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Add Faculty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            GestureDetector(
              onTap: handleImagePick,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: pickedImage != null
                    ? MemoryImage(Uint8List.fromList(pickedImage!.bytes!))
                    : null,
                child: pickedImage == null
                    ? const Icon(Icons.add_a_photo, color: Colors.black54, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedDepartment,
              hint: const Text('Select Department'),
              items: _departmentList.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept['department_id'].toString(),
                  child: Text(dept['department_name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedDepartment = newValue;
                });
              },
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF161616),
                padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 18),
              ),
              onPressed: register,
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
