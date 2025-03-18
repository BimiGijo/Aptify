import 'package:aptify_student/screen/adminhome.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFC107), // Yellow background color
      body: Column(
        children: [
          // Yellow header
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: const Color(0xFFFFC107), // Yellow color
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // White container with rounded top edges
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 50), 
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 30), 
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const SizedBox(height: 30), // Increased spacing
                    ElevatedButton(
                      onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHome() )); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text("Sign In", style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
