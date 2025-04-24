import 'package:aptify_student/screen/takequiz.dart';
import 'package:flutter/material.dart';
import 'package:aptify_student/main.dart';

class Difficulty extends StatefulWidget {
  final Map<String, dynamic> category;

  const Difficulty({super.key, required this.category});

  @override
  State<Difficulty> createState() => _DifficultyState();
}

class _DifficultyState extends State<Difficulty> {
  List<Map<String, dynamic>> difficulties = [];

  @override
  void initState() {
    super.initState();
    fetchDifficulties();
  }

  Future<void> fetchDifficulties() async {
    final List<Map<String, dynamic>> data = await supabase.from('tbl_difficulty').select();
    setState(() {
      difficulties = data;
    });
  }

  /// Function to insert quizhead before navigation
  Future<void> insertQuizHeadAndNavigate(Map<String, dynamic> difficulty) async {
    try {
      // Insert into tbl_quizhead
      final response = await supabase.from('tbl_quizhead').insert({
        'category_id': widget.category['category_id'],   // Foreign key
        'difficulty_id': difficulty['difficulty_id'],    // Foreign key
           
      }).select('quizhead_id').single();

      // Extract the generated quizhead_id
      final quizheadId = response['quizhead_id'];

      // Navigate to the next page with the inserted quizhead ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Takequiz(
            category: widget.category,
            difficulty: difficulty,
            quizheadId: quizheadId,   // Pass the generated ID
          ),
        ),
      );
        } catch (e) {
      print('Error inserting quizhead: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inserting quizhead'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Difficulty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: difficulties.isEmpty
            ? const CircularProgressIndicator()
            : Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: difficulties.length,
                  itemBuilder: (context, index) {
                    final difficulty = difficulties[index];

                    return GestureDetector(
                      onTap: () {
                        if (difficulty['difficulty_name'] != null) {
                          // Insert before navigation
                          insertQuizHeadAndNavigate(difficulty);
                        }
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          alignment: Alignment.center,
                          child: Text(
                            difficulty['difficulty_name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
