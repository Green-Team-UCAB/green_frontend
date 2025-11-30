import 'package:flutter/material.dart';
import 'package:kahoot_project/Presentation//Screens/KahootCreatorScreen.dart';

void main() => runApp(KahootCreatorApp());

class KahootCreatorApp extends StatelessWidget {
    KahootCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kahoot Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.black,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      
      home: KahootCreatorScreen(),
    );
  }
}

