import 'package:flutter/material.dart';
import 'package:green_frontend/core/theme/app_pallete.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/nav_bar_selection_screen.dart';
import 'package:provider/provider.dart';
import 'features/menu_navegation/presentation/providers/navigation_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),  
      ],
    child: MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppPallete.backgroundColor,
      ),
      home: const NavBarSelectionScreen(),
    ),
    );
  }
}
