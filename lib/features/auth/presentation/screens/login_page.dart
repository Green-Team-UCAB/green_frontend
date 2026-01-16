import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:green_frontend/features/auth/presentation/screens/singup_page.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/nav_bar_selection_screen.dart';

// 🔥 IMPORTANTE: Importamos el injection_container para acceder al switch
import '../../../../../injection_container.dart' as di;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Estado local del Switch, inicializado con el valor global actual
  bool _isAlternativeServer = di.isAlternativeServerActive;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLogin(
              username: usernameController.text.trim(),
              password: passwordController.text.trim(),
            ),
          );
    }
  }

  // Función que ejecuta el cambio de backend
  void _toggleBackend(bool value) {
    setState(() {
      _isAlternativeServer = value;
    });

    // Llamamos a la función global que actualiza Dio
    di.switchBackend(value);

    // Feedback visual para saber qué pasó
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? "🌐 Conectado al Backend B (Alternativo)"
              : "🚀 Conectado al Backend A (Principal)",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: value ? Colors.blueAccent : Colors.green,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar para colocar el control de configuración discretamente
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Row(
            children: [
              Text(
                _isAlternativeServer ? "Back B" : "Back A",
                style: TextStyle(
                  color: _isAlternativeServer ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _isAlternativeServer,
                activeColor: Colors.blue,
                inactiveThumbColor: Colors.green,
                trackColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue.withOpacity(0.3);
                  }
                  return Colors.green.withOpacity(0.3);
                }),
                onChanged: _toggleBackend,
              ),
              const SizedBox(width: 12),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is AuthSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => NavBarSelectionScreen()),
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Indicador de ambiente actual (opcional pero útil)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _isAlternativeServer
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _isAlternativeServer
                                    ? Colors.blue
                                    : Colors.green,
                                width: 1)),
                        child: Text(
                          _isAlternativeServer
                              ? "Server: Alternativo (BackComun)"
                              : "Server: Principal (Quizzy)",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isAlternativeServer
                                  ? Colors.blue[800]
                                  : Colors.green[800]),
                        ),
                      ),

                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: usernameController,
                        hintText: 'Username',
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),
                      _buildGradientButton(
                        text: 'Sign In',
                        onPressed: _onLogin,
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 73, 1, 107),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo requerido' : null,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 205, 95, 239),
              Color.fromARGB(255, 73, 1, 107),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
