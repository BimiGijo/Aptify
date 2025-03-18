import 'package:aptify_faculty/screen/leaderboard.dart';
import 'package:aptify_faculty/screen/mystudent.dart';
import 'package:aptify_faculty/screen/profile.dart';
import 'package:aptify_faculty/screen/student.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(FacultyHome());
}

class FacultyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FacultyHomePage(),
    );
  }
}

class FacultyHomePage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.group_add, 'title': 'Manage New Students', 'route' : StudentPage()},
    {'icon': Icons.people, 'title': 'My Students', 'route' : MyStudent()},
    {'icon': Icons.leaderboard, 'title': 'View Leaderboard', 'route' : Leaderboard()},
    {'icon': Icons.person, 'title': 'My Profile', 'route' : Myprofile()},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Faculty Portal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900], // Deep blue matching the gown
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[900],
              image: DecorationImage(
                image: AssetImage('assets/images/faculty.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '"Education is the most powerful weapon which you can use to change the world." – Nelson Mandela',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
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
                      color: Colors.blue[800], // Slightly lighter blue for contrast
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category['icon'], size: 40, color: Colors.white),
                          SizedBox(height: 10),
                          Text(
                            category['title'],
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
