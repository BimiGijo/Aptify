import 'package:flutter/material.dart';

class Appbar extends StatelessWidget {
  const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF14213D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.account_circle,
            color: Color(0xFFfca311),
          ),
          SizedBox(
            width: 10,
          ),
          Text("Admin",
            style: TextStyle(color:  Colors.white)
          ),
          SizedBox(
            width: 40,
          )
        ],
      ),
    );
  }
}