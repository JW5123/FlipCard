import 'package:flutter/material.dart';
import 'pages/game_page.dart';

void main() => runApp(const FlipCardGameApp());

class FlipCardGameApp extends StatelessWidget {
  const FlipCardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '翻牌遊戲',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const FlipCardGamePage(),
    );
  }
}
