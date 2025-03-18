import 'package:aptify_student/screen/leaderboard.dart';
import 'package:aptify_student/screen/quiz.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AdminHome());
}

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.assignment, 'title': 'Take Quiz', 'route' : const Quiz()},
    {'icon': Icons.task, 'title': 'My Quiz'},
    {'icon': Icons.workspace_premium, 'title': 'Leaderboard', 'route' :  Leaderboard()},
    {'icon': Icons.account_circle, 'title': 'My Account'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'APTIFY',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.amber,
              image: DecorationImage(
                image: AssetImage('assets/images/grad.jpg'),
                fit: BoxFit.cover, // Ensures the image covers the entire container
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '"A good education is a foundation for a better future." – Elizabeth Warren',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      if (category['route'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => category['route']),
                        );
                      }
                    },
                    child: Card(
                      color: Colors.white, // Slightly lighter blue for contrast
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category['icon'], size: 40, color: Colors.black),
                          SizedBox(height: 10),
                          Text(
                            category['title'],
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
