import 'package:aptify_subadmin/main.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  // Fetch leaderboard data from Supabase
  Future<void> fetchLeaderboardData() async {
    try {
      // Query tbl_student for all students with college (subadmin) name
      final studentResponse =
          await supabase.from('tbl_student').select('student_id, student_name, tbl_class(tbl_teacher(tbl_subadmin(subadmin_name)))');

      final List<Map<String, dynamic>> students = studentResponse;

      // Query tbl_quizhead for quiz scores
      final quizResponse = await supabase
          .from('tbl_quizhead')
          .select('student_id, student_totalmark');

      final List<Map<String, dynamic>> quizResults = quizResponse;

      // Aggregate scores by student_id
      Map<String, int> scoreMap = {};
      for (var result in quizResults) {
        final studentId = result['student_id'] as String;
        final score = result['student_totalmark'] ?? 0;
        scoreMap[studentId] = (scoreMap[studentId] ?? 0) + (score as int);
      }

      // Build leaderboard with college name
      List<Map<String, dynamic>> leaderboardData = students.map((student) {
        String college = '';
        try {
          college = student['tbl_class']?['tbl_teacher']?['tbl_subadmin']?['subadmin_name'] ?? '';
        } catch (_) {}
        return {
          'id': student['student_id'] as String,
          'name': student['student_name'] as String,
          'college': college,
          'score': scoreMap[student['student_id']] ?? 0,
        };
      }).toList();

      // Sort by score descending
      leaderboardData.sort((a, b) => b['score'].compareTo(a['score']));

      // Assign ranks
      for (int i = 0; i < leaderboardData.length; i++) {
        leaderboardData[i]['rank'] = i + 1;
      }

      // Only keep top 10 students
      leaderboardData = leaderboardData.take(10).toList();

      setState(() {
        leaderboard = leaderboardData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching leaderboard: $e';
      });
      print('Error fetching leaderboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Admin Box (Full Width)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: const [
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

                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

// Leaderboard - Top 10
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffeeeeee),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      height: 500,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Leaderboard - Top 10',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F4037),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: leaderboard.isEmpty
                                ? const Center(child: Text('No data available'))
                                : ListView.builder(
                                    itemCount: leaderboard.length,
                                    itemBuilder: (context, index) {
                                      final player = leaderboard[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${player['rank']}.',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    player['name'],
                                                    style: const TextStyle(fontSize: 18),
                                                  ),
                                                  Text(
                                                    player['college'] ?? '',
                                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '${player['score']}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
    );
  }
}
