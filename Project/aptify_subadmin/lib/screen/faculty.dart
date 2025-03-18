import 'dart:io';
import 'dart:typed_data';
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

  PlatformFile? pickedImage; // Store selected image
  List<Map<String, dynamic>> _departmentList = [];
  String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    fetchDepartment();
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

  // Function to pick image
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
      if (uid.isNotEmpty || uid != "") {
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

      if(selectedDepartment == null) {
        print('Department not Selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a department", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (url != null) {
        await supabase.from('tbl_teacher').insert({
          'teacher_id': uid,
          'department_id' : selectedDepartment,
          'teacher_name': name,
          'teacher_contact': contact,
          'teacher_email': email,
          'teacher_password': password,
          'teacher_photo': url
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Teacher Details Added", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        // Clear inputs
        _nameController.clear();
        _passwordController.clear();
        _emailController.clear();
        _contactController.clear();

        setState(() {
          pickedImage = null;
          selectedDepartment = null;
        });
      } else {
        print("Teacher profile not given");
      }
    } catch (e) {
      print("Error Inserting Teacher Details: $e");
    }
  }

  // Upload Image to Supabase Storage
  Future<String?> photoUpload(String uid) async {
    if (pickedImage == null) return null;
    try {
      final bucketName = 'teacher'; // Supabase storage bucket name
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manage Faculty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF161616),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                  });
                },
                label: Text(_isFormVisible ? "Cancel" : "Add", style: TextStyle(color: Colors.white)),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add, color: Colors.white),
              ),
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Form(
                    child: Container(
                      height: 550,
                      width: 400,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 246, 243, 243).withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Add Faculty",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 15),
                            // Image Upload Button
                            GestureDetector(
                              onTap: handleImagePick,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: pickedImage != null
                                    ? MemoryImage(Uint8List.fromList(pickedImage!.bytes!))
                                    : null,
                                child: pickedImage == null
                                    ? Icon(Icons.add_a_photo, color: Colors.black54, size: 30)
                                    : null,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),

                            DropdownButtonFormField<String>(
                              value: selectedDepartment,
                              hint: Text('Select Department'),
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
                            SizedBox(height: 10),

                            TextFormField(
                              controller: _contactController,
                              decoration: InputDecoration(
                                labelText: 'Contact',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF161616),
                                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18),
                              ),
                              onPressed: register,
                              child: Text('Submit', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }
}
