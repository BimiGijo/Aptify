import 'package:aptify_student/main.dart';
import 'package:aptify_student/screen/adminhome.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:aptify_student/screen/quiz.dart';

class QuizSuccess extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int quizheadId;

  const QuizSuccess({
    super.key,
    required this.score,
    required this.totalQuestions, required this.quizheadId,
  });

  @override
  State<QuizSuccess> createState() => _QuizSuccessState();
}

class _QuizSuccessState extends State<QuizSuccess> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scoreUpdate();
  }

  Future<void> scoreUpdate() async {
    await supabase.from('tbl_quizhead')
                     .update({
                      'student_totalmark' : widget.score
                     }).eq('quizhead_id', widget.quizheadId);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentage score
    final percentage = (widget.score / widget.totalQuestions * 100).round();
    
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade500, Colors.amber.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Blur Layer for Depth
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Trophy Icon
                Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.white,
                ),
                
                const SizedBox(height: 20),
                
                // Congratulations Text
                const Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Motivational Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "You've successfully completed the quiz!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Score Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            "Your Score",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Score Circle
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.amber.shade400, Colors.orange.shade500],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$percentage%",
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${widget.score}/${widget.totalQuestions}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Performance Message
                          Text(
                            _getPerformanceMessage(percentage),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      // Retake Quiz Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Quiz()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.amber.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Retake Quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Home Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHome()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.amber.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Back to Home",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get performance message based on score percentage
  String _getPerformanceMessage(int percentage) {
    if (percentage >= 90) {
      return "Excellent! You've mastered this topic!";
    } else if (percentage >= 75) {
      return "Great job! You have a solid understanding!";
    } else if (percentage >= 60) {
      return "Good work! Keep practicing to improve!";
    } else {
      return "Keep learning! Try again to improve your score.";
    }
  }
}

