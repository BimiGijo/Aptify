import 'package:aptify_admin/main.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key:key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<Map<String, dynamic>> feedbacks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  // Fetch feedbacks and submitter names
  Future<void> fetchFeedbacks() async {
    try {
      // Fetch feedbacks
      final feedbackResponse = await supabase
          .from('tbl_feedback')
          .select('id, created_at, feedback_content, teacher_id, student_id')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> feedbackData = feedbackResponse;

      // Fetch student names
      final studentResponse = await supabase
          .from('tbl_student')
          .select('student_id, student_name');
      final Map<String, String> studentNames = {
        for (var s in studentResponse) s['student_id']: s['student_name']
      };

      // Fetch teacher names
      final teacherResponse = await supabase
          .from('tbl_teacher')
          .select('teacher_id, teacher_name');
      final Map<String, String> teacherNames = {
        for (var t in teacherResponse) t['teacher_id']: t['teacher_name']
      };

      // Combine data
      final enrichedFeedbacks = feedbackData.map((feedback) {
        final isTeacher = feedback['teacher_id'] != null;
        final submitterId = isTeacher ? feedback['teacher_id'] : feedback['student_id'];
        final submitterName = isTeacher
            ? (teacherNames[submitterId] ?? 'Unknown Teacher')
            : (studentNames[submitterId] ?? 'Unknown Student');
        return {
          ...feedback,
          'submitter_name': submitterName,
          'submitter_type': isTeacher ? 'Teacher' : 'Student',
        };
      }).toList();

      setState(() {
        feedbacks = enrichedFeedbacks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching feedbacks: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feedbacks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedbacks.isEmpty
              ? const Center(child: Text('No feedbacks found'))
              : RefreshIndicator(
                  onRefresh: fetchFeedbacks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbacks[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Submitter Info
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${feedback['submitter_name']} (${feedback['submitter_type']})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Feedback Content
                              Text(
                                'Feedback: ${feedback['feedback_content']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${DateTime.parse(feedback['created_at']).toLocal().toString().split('.')[0]}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}