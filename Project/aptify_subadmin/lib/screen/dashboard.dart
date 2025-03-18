import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Admin Box (Full Width)
          Container(
            width: double.infinity, // Stretch full width
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Text(
              "Welcome!",
              style: TextStyle(
                color: Color(0xFF1F4037),
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 20), // Space below Welcome box

          // First Row - Two Big Boxes
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffeeeeee),
                  ),
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  child: const Text('Add Any Text', style: TextStyle(fontSize: 18),),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffeeeeee),
                  ),
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  child: const Text("Add Any Text", style: TextStyle(fontSize: 18),),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),


        ],
      ),
    );
  }
}
