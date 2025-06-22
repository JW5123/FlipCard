import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const FlipCardGameApp());
}

class FlipCardGameApp extends StatelessWidget {
  const FlipCardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '翻牌記憶',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade50,
          foregroundColor: Colors.teal.shade800,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}