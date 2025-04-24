import 'dart:ui';
import 'package:aptify_faculty/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Leaderboard extends StatefulWidget {

  const Leaderboard({super.key});

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  // Fetch leaderboard data from Supabase
  Future<List<Map<String, dynamic>>> fetchLeaderboardData() async {
    try {
      // Query tbl_student for all students with department
      final studentResponse = await Supabase.instance.client
          .from('tbl_student')
          .select('student_id, student_name, tbl_class(tbl_course(tbl_department(department_name)))');

      final List<Map<String, dynamic>> students = studentResponse;

      // Query tbl_quizhead for quiz scores
      final quizResponse = await Supabase.instance.client
          .from('tbl_quizhead')
          .select('student_id, student_totalmark');

      final List<Map<String, dynamic>> quizResults = quizResponse;

      // Aggregate scores by student_id
      Map<String, int> scoreMap = {};
      for (var result in quizResults) {
        final studentId = result['student_id'] as String;
        final score = (result['student_totalmark'] ?? 0) as int;
        scoreMap[studentId] = (scoreMap[studentId] ?? 0) + score;
      }

      // Build leaderboard with department
      List<Map<String, dynamic>> leaderboard = students.map((student) {
        // Safely extract department name
        String department = '';
        try {
          department = student['tbl_class']?['tbl_course']?['tbl_department']?['department_name'] ?? '';
        } catch (_) {}
        return {
          'id': student['student_id'] as String,
          'name': student['student_name'] as String,
          'department': department,
          'score': scoreMap[student['student_id']] ?? 0,
        };
      }).toList();

      // Sort by score descending
      leaderboard.sort((a, b) => b['score'].compareTo(a['score']));

      // Assign ranks
      for (int i = 0; i < leaderboard.length; i++) {
        leaderboard[i]['rank'] = i + 1;
      }

      return leaderboard;
    } catch (e) {
      print('Failed to fetch leaderboard data: $e');
      throw Exception('Failed to fetch leaderboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Trigger rebuild to refresh data
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchLeaderboardData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final leaderboard = snapshot.data!;

            return Stack(
              children: [
                // Gradient Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[700]!, Colors.lightBlueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
                  ),
                ),
                // Blur Layer
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.white.withOpacity(0.05)),
                  ),
                ),
                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Leaderboard",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Top 3 Players
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (leaderboard.length > 1)
                            _buildTopPlayer(
                              "2nd",
                              leaderboard[1]['name'],
                              leaderboard[1]['score'],
                              40,
                              'assets/images/second.png',
                              isCurrentUser: leaderboard[1]['id'] == supabase.auth.currentUser!.id,
                            ),
                          if (leaderboard.isNotEmpty)
                            _buildTopPlayer(
                              "1st",
                              leaderboard[0]['name'],
                              leaderboard[0]['score'],
                              50,
                              'assets/images/first.png',
                              isWinner: true,
                              isCurrentUser: leaderboard[0]['id'] == supabase.auth.currentUser!.id,
                            ),
                          if (leaderboard.length > 2)
                            _buildTopPlayer(
                              "3rd",
                              leaderboard[2]['name'],
                              leaderboard[2]['score'],
                              40,
                              'assets/images/third.png',
                              isCurrentUser: leaderboard[2]['id'] == supabase.auth.currentUser!.id,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Leaderboard List
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ListView.builder(
                              itemCount: leaderboard.length,
                              itemBuilder: (context, index) {
                                var player = leaderboard[index];
                                return _buildLeaderboardTile(
                                  player['name'],
                                  player['rank'],
                                  player['score'],
                                  player['id'] == supabase.auth.currentUser!.id,
                                  player['department'], // Pass department here
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopPlayer(
    String rank,
    String name,
    int score,
    double size,
    String imagePath, {
    bool isWinner = false,
    bool isCurrentUser = false,
  }) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: size * 2,
            height: size * 2,
            fit: BoxFit.cover,
          ),
        ),
        if (isWinner) const SizedBox(height: 5),
        Text(
          rank,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          isCurrentUser ? "$name (YOU)" : name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isCurrentUser ? const Color.fromARGB(255, 255, 242, 4) : Colors.black,
          ),
        ),
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(String name, int rank, int score, bool isCurrentUser, [String? department]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue.shade50 : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.account_circle, color: Colors.white),
          ),
          title: Text(
            isCurrentUser ? "$name (YOU)" : name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? Colors.blue : Colors.black,
            ),
          ),
          subtitle: department != null && department.isNotEmpty
              ? Text("Rank $rank\nDept: $department")
              : Text("Rank $rank"),
          trailing: Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}