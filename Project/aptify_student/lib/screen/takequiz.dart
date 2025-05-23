import 'dart:async';
import 'dart:convert';
import 'package:aptify_student/screen/adminhome.dart';
import 'package:aptify_student/screen/quizSuccess.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aptify_student/main.dart'; // Ensure you import supabase

class Takequiz extends StatefulWidget {
  final Map<String, dynamic> difficulty;
  final Map<String, dynamic> category;
  final int quizheadId;

  const Takequiz({super.key, required this.difficulty, required this.category, required this.quizheadId});

  @override
  State<Takequiz> createState() => _TakequizState();
}

class _TakequizState extends State<Takequiz> {
  int currentQuestion = 0;
  List<Map<String, dynamic>> quizData = [];
  bool isLoading = true;
  String? selectedOption;
  bool isAnswered = false;
  int totalMark = 0;
  Timer? _timer;
  int _remainingSeconds = 10 * 60; // 10 minutes in seconds
  bool _timerStarted = false; // Flag to prevent multiple timer starts

  @override
  void initState() {
    super.initState();
    fetchQstns();
  }

  // Start the 10-minute timer
  void startTimer() {
    if (_timerStarted) return; // Prevent starting multiple timers
    _timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // Time's up, save current answer and end quiz
          timer.cancel();
          insertAnswer(); // Save the last answer if any
          endQuiz();
        }
      });
    });
  }

  // Format remaining time as MM:SS
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // End the quiz and navigate to QuizSuccess
  void endQuiz() {
    _timer?.cancel();
    _timerStarted = false;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSuccess(
          quizheadId: widget.quizheadId,
          score: totalMark,
          totalQuestions: quizData.length,
        ),
      ),
    );
  }

  // Fetch questions
  Future<void> fetchQstns() async {
    Set<String> uniqueQuestions = {};
    List<Map<String, dynamic>> questionList = [];

    try {
      String url = widget.category['category_link'];
      int count = widget.difficulty['qn_count'];

      questionList.clear();

      while (questionList.length < count) {
        final response = await http.get(Uri.parse('$url'));

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);

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

        if (questionList.length >= count) break;
      }

      setState(() {
        quizData = questionList;
        isLoading = false;
        // Start the timer only if questions are successfully loaded
        if (quizData.isNotEmpty) {
          startTimer();
        }
      });

      print('Fetched ${quizData.length} unique questions.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching questions: $e");
    }
  }

  // Insert the answer into the tbl_quiz
  Future<void> insertAnswer() async {
    if (quizData.isEmpty || selectedOption == null) return;

    var currentQn = quizData[currentQuestion];
    int mark = (selectedOption == currentQn['answer']) ? 1 : 0;

    totalMark = totalMark + mark;
    try {
      await supabase.from('tbl_quiz').insert({
        'quizhead_id': widget.quizheadId,
        'quiz_question': currentQn['question'],
        'quiz_selectanswer': selectedOption,
        'quiz_correctanswer': currentQn['answer'],
        'quiz_mark': mark,
      });
    } catch (e) {
      print('Failed to insert answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save answer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void checkAnswer(String option) {
    setState(() {
      selectedOption = option;
      isAnswered = true;
    });

    insertAnswer();
  }

  void nextQuestion() {
    if (currentQuestion < quizData.length - 1) {
      setState(() {
        currentQuestion++;
        selectedOption = null;
        isAnswered = false;
      });
    } else {
      endQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.amber,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var question = quizData[currentQuestion];

    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog before exiting the quiz
        bool? exitQuiz = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit Quiz"),
            content: const Text("Are you sure you want to exit the quiz?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomePage(),),(route) => false,),
                child: const Text("Exit"),
              ),
            ],
          ),
        );
        return exitQuiz ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.amber[100],
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quiz",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _remainingSeconds <= 60 ? Colors.red : Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formatTime(_remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
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
                      ),
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
                  onPressed: () {
                    if (selectedOption == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select an Option')),
                      );
                    } else {
                      nextQuestion();
                    }
                  },
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
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}