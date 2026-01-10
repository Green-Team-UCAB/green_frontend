import 'package:flutter/material.dart';
import 'package:green_frontend/features/auth/presentation/screens/login_page.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/nav_bar_selection_screen.dart';
import 'package:green_frontend/core/storage/token_storage.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Fade in
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 1));

    // Fade out
    await _controller.reverse();

    await TokenStorage.deleteToken();

    // Navegación según token
    final token = await TokenStorage.getToken();

    if (!mounted) return;

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavBarSelectionScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/purpleicon2.png', 
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                "Quizzy",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 124, 12, 136),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

