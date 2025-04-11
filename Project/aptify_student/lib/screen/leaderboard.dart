import 'dart:ui';
import 'package:flutter/material.dart';

class Leaderboard extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard = [
    {"name": "Cameron Black", "score": 122585, "rank": 4},
    {"name": "Gladys Fisher", "score": 122583, "rank": 5},
    {"name": "Jennie Warren", "score": 122543, "rank": 6},
    {"name": "Audrey Bell", "score": 122512, "rank": 7},
    {"name": "Tyrone Hawkins", "score": 122431, "rank": 8},
    {"name": "Michael Brown", "score": 122400, "rank": 9},
    {"name": "Alice Cooper", "score": 122350, "rank": 10},
    {"name": "Robert King", "score": 122300, "rank": 11},
    {"name": "Emma Stone", "score": 122250, "rank": 12},
    {"name": "Sophia Carter", "score": 122200, "rank": 13},
    {"name": "Liam Johnson", "score": 122150, "rank": 14},
    {"name": "Oliver Smith", "score": 122100, "rank": 15},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // **Gradient Background**
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade500, Colors.amber.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // **Blur Layer for Depth**
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // **Leaderboard Content**
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // **Title**
                const Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                

                const SizedBox(height: 20),

                // **Top 3 Players with Smaller Avatars**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopPlayer("2nd", 122700, 40, 'assets/images/second.png'),
                    _buildTopPlayer("1st", 122900, 50, 'assets/images/first.png', isWinner: true),
                    _buildTopPlayer("3rd", 122600, 40, 'assets/images/third.png'),
                  ],
                ),

                const SizedBox(height: 20),

                // **Scrollable White Box for Leaderboard**
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
                            player["name"],
                            player["rank"],
                            player["score"],
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
      ),
    );
  }

  // **Top 3 Players Widget**
  Widget _buildTopPlayer(String rank, int score, double size, String imagePath, {bool isWinner = false}) {
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
        if (isWinner)
        const SizedBox(height: 5),
        Text(rank, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(score.toString(), style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // **Leaderboard List Tile**
  Widget _buildLeaderboardTile(String name, int rank, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Number $rank"),
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
