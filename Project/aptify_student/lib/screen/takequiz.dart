import 'dart:convert';  
import 'package:flutter/material.dart';  
import 'package:http/http.dart' as http;  

class Takequiz extends StatefulWidget {
  final Map<String, dynamic> difficulty;
  final Map<String, dynamic> category;
  const Takequiz({super.key, required this.difficulty, required this.category});

  @override
  State<Takequiz> createState() => _TakequizState();
}

class _TakequizState extends State<Takequiz> {
  int currentQuestion = 0;
  List<Map<String, dynamic>> quizData = [];
  bool isLoading = true;
  String? selectedOption;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    fetchQstns();
  }

  // ✅ Fetch questions with no duplicates
  Future<void> fetchQstns() async {
    Set<String> uniqueQuestions = {};  // To store unique questions
    List<Map<String, dynamic>> questionList = [];

    try {
      String url = widget.category['category_link'];
      int count = widget.difficulty['qn_count'];

      questionList.clear();

      while (questionList.length < count) {
        final response = await http.get(Uri.parse('$url'));

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);

          // Handle both single and multiple responses
          if (jsonData is List) {
            for (var item in jsonData) {
              String questionText = item['question'] ?? '';
              if (!uniqueQuestions.contains(questionText)) {
                uniqueQuestions.add(questionText);
                questionList.add(item);
              }
            }
          } else if (jsonData is Map<String, dynamic>) {
            String questionText = jsonData['question'] ?? '';
            if (!uniqueQuestions.contains(questionText)) {
              uniqueQuestions.add(questionText);
              questionList.add(jsonData);
            }
          }
        } else {
          print('Failed to load question: ${response.statusCode}');
        }

        // Exit the loop early if we have enough questions
        if (questionList.length >= count) break;
      }

      setState(() {
        quizData = questionList;
        isLoading = false;
      });

      print('Fetched ${quizData.length} unique questions.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching questions: $e");
    }
  }

  void checkAnswer(String option) {
    setState(() {
      selectedOption = option;
      isAnswered = true;
    });
  }

  void nextQuestion() {
    if (currentQuestion < quizData.length - 1) {
      setState(() {
        currentQuestion++;
        selectedOption = null;
        isAnswered = false;
      });
    } else {
      // Quiz completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz Completed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Prevent RangeError by checking if the data is available
    if (isLoading || quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Quiz", style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.amber,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var question = quizData[currentQuestion];

    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        /*leading: IconButton(
          onPressed: () => fetchQstns(),
          icon: const Icon(Icons.refresh),
        ),*/
        title: const Text(
          "Quiz",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Question ${currentQuestion + 1} of ${quizData.length}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
          
              // Box for question and options
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        question["question"],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      ...question["options"].map<Widget>((option) {
                        bool isCorrect = option == question["answer"];
                        bool isSelected = option == selectedOption;
                  
                        Color tileColor = Colors.white;
                        IconData icon = Icons.radio_button_unchecked;
                        Color iconColor = Colors.grey;
                  
                        if (isAnswered) {
                          if (isSelected && isCorrect) {
                            tileColor = Colors.lightGreen[100]!;
                            icon = Icons.check_circle;
                            iconColor = Colors.green;
                          } else if (isSelected && !isCorrect) {
                            tileColor = Colors.red[100]!;
                            icon = Icons.cancel;
                            iconColor = Colors.red;
                          } else if (!isSelected && isCorrect) {
                            tileColor = Colors.lightGreen[100]!;
                            icon = Icons.check_circle;
                            iconColor = Colors.green;
                          }
                        }
                  
                        return GestureDetector(
                          onTap: isAnswered ? null : () => checkAnswer(option),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ListTile(
                              leading: Icon(icon, color: iconColor),
                              title: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Next", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
