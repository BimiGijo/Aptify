import 'dart:io';
import 'package:aptify_faculty/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aptify_faculty/screen/changepassword.dart';
import 'package:flutter/material.dart';


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
  String photo = "";
  String uid = '';

  File? _image;
  final ImagePicker _picker = ImagePicker();

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
    final fileName = 'profile_$uid.jpg';
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
        name = response['teacher_name'] ;
        email = response['teacher_email'];
        contact = response['teacher_contact'];
        photo = response['teacher_photo'] ;
      });
    } catch (e) {
      print('Error Fetching profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void editName() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Change Number'),
        content: Form(
          child: TextFormField(
            controller: _contactController,
            decoration: InputDecoration(
              hintText: 'Contact',
              border: OutlineInputBorder()
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text('Cancel')),
          TextButton(onPressed: () {
            update(uid);
          }, child: Text('OK')),

        ],
      );
    },);
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
        title: const Text("My Profile", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: photo.isNotEmpty
                      ? NetworkImage(photo)
                      : null,
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
                            child: Icon(
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

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Changepassword()),
                  );
                },
                //icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
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
              edit ? IconButton(onPressed: editName, icon: Icon(Icons.edit)) : SizedBox()

            ],
          ),
        ),
      ],
    );
  }
}
