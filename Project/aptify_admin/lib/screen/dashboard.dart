import 'package:aptify_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key:key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int collegeCount = 0;
  int teacherCount = 0;
  int studentCount = 0;
  int quizCount = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCount();
  }

  Future<void> fetchCount() async {
    try {
      final college = await supabase.from('tbl_subadmin').count();
      final teacher = await supabase.from('tbl_teacher').count();
      final student = await supabase.from('tbl_student').count();
      final quiz = await supabase.from('tbl_quizhead').count();

      setState(() {
        collegeCount = college;
        teacherCount = teacher;
        studentCount = student;
        quizCount = quiz;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF14213D),
                      ),
                      child: const Text(
                        "Welcome Admin!",
                        style: TextStyle(
                          color: Color(0xFFfca311),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Charts Section
                    Row(
                      children: [
                        // Pie Chart for Users
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                            ),
                            child: Column(
                              children: [
                                const Text("User Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                AspectRatio(
                                  aspectRatio: 1.3,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        PieChartSectionData(
                                          value: studentCount.toDouble(),
                                          color: Colors.blueAccent,
                                          title: 'Students',
                                          titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                        PieChartSectionData(
                                          value: teacherCount.toDouble(),
                                          color: Colors.orange,
                                          title: 'Teachers',
                                          titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                        PieChartSectionData(
                                          value: collegeCount.toDouble(),
                                          color: Colors.green,
                                          title: 'Colleges',
                                          titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Stats Summary
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _buildStatCard("Total Students", studentCount, Icons.school),
                              const SizedBox(height: 16),
                              _buildStatCard("Total Teachers", teacherCount, Icons.person),
                              const SizedBox(height: 16),
                              _buildStatCard("Total Colleges", collegeCount, Icons.account_balance),
                              const SizedBox(height: 16),
                              _buildStatCard("Total Quizzes", quizCount, Icons.quiz),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Status box
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info, color: Colors.green, size: 32),
                          SizedBox(width: 12),
                          Text("System Status: Operational", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffeeeeee),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: const Color(0xFFfca311)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('$count', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
