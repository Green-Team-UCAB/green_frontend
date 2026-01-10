import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: "Carlos David");
  final _emailController = TextEditingController(text: "ncarloss@example.com");
  final _usernameController = TextEditingController(text: "carlitos123");
  final _passwordController = TextEditingController(text: "********");
  
  String _selectedType = "student"; // Para el campo 'type'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos un Stack para las formas decorativas del fondo
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Forma decorativa superior (el "manchón" púrpura/azul)
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Botón de regreso y Título
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Edit Profile",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance para el centrado
                      ],
                    ),
                  ),
                ),
                // Avatar centrado
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFE0E0E0),
                        child: Icon(Icons.person, size: 55, color: Colors.white), 
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),

            // FORMULARIO DE CAMPOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Name"),
                  _buildInputField(_nameController, Icons.person_outline),
                  
                  _buildLabel("Email"),
                  _buildInputField(_emailController, Icons.email_outlined),
                  
                  _buildLabel("Username"),
                  _buildInputField(_usernameController, Icons.alternate_email),
                  
                  _buildLabel("Password"),
                  _buildInputField(_passwordController, Icons.lock_outline, obscureText: true),
                  
                  _buildLabel("Type"),
                  _buildTypeSelector(),

                  const SizedBox(height: 40),
                  
                  // Botón "Complete" / Guardar
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A00E0).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Complete",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Estilo de etiqueta similar a la imagen
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Campo de texto minimalista con línea inferior
  Widget _buildInputField(TextEditingController controller, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1C4E9))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6E48AA), width: 2)),
        suffixIcon: Icon(icon, color: const Color(0xFF9D50BB), size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  // Selector de Tipo (Student / Teacher) similar a los radios de la imagen
  Widget _buildTypeSelector() {
    return Row(
      children: [
        Radio<String>(
          value: "student",
          groupValue: _selectedType,
          activeColor: const Color(0xFF9D50BB),
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
        const Text("Student"),
        const SizedBox(width: 20),
        Radio<String>(
          value: "teacher",
          groupValue: _selectedType,
          activeColor: const Color(0xFF9D50BB),
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
        const Text("Teacher"),
      ],
    );
  }
}

// Clase para crear la curva orgánica del fondo
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(size.width * 0.8, size.height - 90, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}