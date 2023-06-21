import 'package:flutter/material.dart';

class Service extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),  // 背景色を「#f0f0f0」に設定
      body: Center(
        child: Text(
          "service",
          style: TextStyle(
              fontSize: 20
          ),
        ),
      ),
    );
  }
}