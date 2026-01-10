import 'package:flutter/material.dart';
import 'package:green_frontend/features/auth/presentation/screens/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'dart:developer' as dev;

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (_) => const SignUpPage());
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

void _onSignUp() {
  if (formKey.currentState!.validate()) {
    dev.log("UI inputs => name=${nameController.text}, email=${emailController.text}, password=${passwordController.text}");
    context.read<AuthBloc>().add(
      AuthSignUp(
        userName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  // Navegar a la pantalla para iniciar sesión 
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
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
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: nameController,
                        hintText: 'Name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),
                      _buildGradientButton(
                        text: 'Sign Up',
                        onPressed: _onSignUp,
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Sign In',
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
          value == null || value.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
