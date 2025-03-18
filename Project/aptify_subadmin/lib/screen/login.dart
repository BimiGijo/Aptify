import 'dart:ui'; // Import for blur effect
import 'package:aptify_subadmin/screen/adminhome.dart';
import 'package:aptify_subadmin/screen/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';
//import 'package:cherry_toast/cherry_toast.dart';
//import 'package:cherry_toast/resources/arrays.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  bool passkey = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)=>AdminHome()));
    } catch (e) {
      print('Error in Logging In');
      /*CherryToast.error(
        description: Text('Invalid Email or Password',
           style: TextStyle(color: Colors.black)),
        animationType: AnimationType.fromRight,
        animationDuration: Duration(milliseconds: 1000),
        autoDismiss: true).show(context);
      print('Invalid Email or Password');*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Image with Blur Effect
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Image.asset(
                '../assets/images/nirmala.jpg', // Ensure correct path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 🔹 Login Card
          Center(
            child: Container(
              height: 500,
              width: 900,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // Slight transparency
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Login Form Section
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back, Admin!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your Password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passkey = !passkey;
                                  });
                                }, 
                              icon: Icon(passkey
                                          ? Icons.visibility_off
                                          : Icons.visibility)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            obscureText: passkey,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminHome(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 🔹 Image Section Inside the Card - Now Fully Utilizing Space
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      child: SizedBox.expand( // Ensures the image takes full available space
                        child: Image.asset(
                          '../assets/images/nirmala.jpg',
                          fit: BoxFit.cover, // Ensures the image fills the space properly
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
