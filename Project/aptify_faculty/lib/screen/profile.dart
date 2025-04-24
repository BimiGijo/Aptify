import 'dart:io';
import 'package:aptify_faculty/main.dart';
import 'package:aptify_faculty/screen/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aptify_faculty/screen/changepassword.dart';
import 'package:flutter/material.dart';
import 'package:aptify_faculty/screen/complaint_screen.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  final TextEditingController _contactController = TextEditingController();

  String name = "";
  String email = "";
  String contact = "";
  String? photo ;
  String uid = '';

  File? _image;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true; // Add this line

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      await uploadImage();
    }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } 
  }

  Future<void> uploadImage() async {
  if (_image == null) return;

  try {
    final fileName = 'profile_$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageBytes = await _image!.readAsBytes();

    // Upload the image
    await supabase.storage.from('teacher').uploadBinary(
      fileName,
      imageBytes,
    );

    // Retrieve the public URL of the uploaded image
    final publicUrl = supabase.storage.from('teacher').getPublicUrl(fileName);

    // Update the profile picture URL in the database
    await supabase
        .from('tbl_teacher')
        .update({'teacher_photo': publicUrl})
        .eq('teacher_id', uid);

    // Update the UI with the new photo
    setState(() {
      photo = publicUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error uploading image: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  Future<void> fetchProfile() async {
    try {
      uid = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('tbl_teacher')
          .select()
          .eq('teacher_id', uid)
          .single();

      setState(() {
        name = response['teacher_name'] ?? 'N/A';
        email = response['teacher_email'] ?? 'N/A';
        contact = response['teacher_contact'] ?? 'N/A';
        photo = response['teacher_photo'] ?? '';
        _isLoading = false; // Set loading to false after data is fetched
      });
    } catch (e) {
      print('Error Fetching profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false; // Also stop loading on error
      });
    }
  }

  void editName() {
  final _formKey = GlobalKey<FormState>();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Change Number'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Contact',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Contact number is required';
              }
              if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                return 'Enter a valid 10-digit number';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                update(uid);
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  Future<void> update(String uid) async {
    try {
      await supabase.from('tbl_teacher').update({
        'teacher_contact' : _contactController.text.trim()
      }).eq('teacher_id', uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile Updated',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _contactController.clear();
      fetchProfile();
      Navigator.pop(context);
    } catch (e) {
      print('Error Updating Data: $e');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            onSelected: (value) async {
              if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Changepassword()),
                );
              } else if (value == 'feedback') {
                final feedbackController = TextEditingController();
                bool isSubmitting = false;
                await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        title: const Text('Submit Feedback'),
                        content: TextField(
                          controller: feedbackController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Your feedback',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: isSubmitting ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setState(() => isSubmitting = true);
                                    try {
                                      await supabase.from('tbl_feedback').insert({
                                        'teacher_id': uid,
                                        'feedback_content': feedbackController.text.trim(),
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Feedback submitted!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() => isSubmitting = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Submit'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (value == 'complaint') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_password',
                child: Text('Change Password'),
              ),
              const PopupMenuItem(
                value: 'feedback',
                child: Text('Feedback'),
              ),
              const PopupMenuItem(
                value: 'complaint',
                child: Text('Complaints'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while loading
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                      photo=="" ? CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[300],
                        child: Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 40),),
                      ) : CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: NetworkImage(photo!),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[900],
                              shape: BoxShape.circle
                            ),
                            padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white,
                                    size: 25,
                                  ),

                          ),
                        ),
                      )
                      ],
                    ),
                    
                  ),

                  const SizedBox(height: 20),

                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Email
                  buildProfileInfoRow(Icons.email, "Email", email),

                  const SizedBox(height: 15),

                  // Contact
                  buildProfileInfoRow(Icons.phone, "Contact", contact, edit: true),

                  const SizedBox(height: 40),

                  ElevatedButton.icon(onPressed: () async{
                    await supabase.auth.signOut();
                    if(!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginScreen()), 
                      (Route<dynamic> route) => false );
                  }, 
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),),
                      ),
                      )
                ],
              ),
            ),
    );
  }

  // Widget for displaying profile info
  Widget buildProfileInfoRow(IconData icon, String label, String value, {bool edit = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[900], size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              edit ? IconButton(onPressed: editName, icon: const Icon(Icons.edit)) : const SizedBox()

            ],
          ),
        ),
      ],
    );
  }
}
