import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/theme_provider.dart';
import 'package:kahoot_project/features/kahoot/presentation/screens/create_kahoot_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KahootProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: 'Kahoot Creator',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CreateKahootScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}