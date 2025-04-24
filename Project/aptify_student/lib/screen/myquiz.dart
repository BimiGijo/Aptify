import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Myquiz extends StatefulWidget {
  const Myquiz({super.key});

  @override
  State<Myquiz> createState() => _MyquizState();
}

class _MyquizState extends State<Myquiz> {
  late Future<List<Map<String, dynamic>>> _quizFuture;

  @override
  void initState() {
    super.initState();
    _quizFuture = fetchAttendedQuizzes();
  }

  Future<List<Map<String, dynamic>>> fetchAttendedQuizzes() async {
    try {
      print("fetchAttendedQuizzes called");
    final uid = Supabase.instance.client.auth.currentUser!.id;
    print("uid: $uid");
    final response = await Supabase.instance.client
        .from('tbl_quizhead')
        .select()
        .eq('student_id', uid);
        print("response: $response");
    return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Handle any errors that occur during the fetch
      print('Error fetching quizzes: $e');
      return []; // Return an empty list in case of error
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Quizzes')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _quizFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No quizzes attended.'));
          }
          final quizzes = snapshot.data!;
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return ListTile(
                title: Text(quiz['quiz_title'] ?? 'Quiz'),
                subtitle: Text('Mark: ${quiz['student_totalmark'] ?? 0}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizDetailPage(quizheadId: quiz['quizhead_id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class QuizDetailPage extends StatelessWidget {
  final int quizheadId;
  const QuizDetailPage({super.key, required this.quizheadId});

  Future<List<Map<String, dynamic>>> fetchQuizDetails() async {
    // Replace with your actual table/fields for questions, attended answer, real answer
    final response = await Supabase.instance.client
        .from('tbl_quiz')
        .select()
        .eq('quizhead_id', quizheadId);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Details')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuizDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No details found.'));
          }
          final questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(q['quiz_question'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Answer: ${q['quiz_selectanswer'] ?? ''}'),
                      Text('Correct Answer: ${q['quiz_correctanswer'] ?? ''}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}