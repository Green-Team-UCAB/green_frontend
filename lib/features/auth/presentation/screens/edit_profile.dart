import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/user/presentation/profile_bloc.dart';
import 'package:green_frontend/features/user/presentation/profile_event.dart';
import 'package:green_frontend/features/user/presentation/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controladores con los nombres exactos de tu Entidad User
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _userNameController; // Coincide con tu Entidad
  late TextEditingController _passwordController;
  String _selectedType = "student"; 

  @override
  void initState() {
    super.initState();
    
    // Recuperamos el estado actual para precargar los datos
    final state = context.read<ProfileBloc>().state;
    
    String initialName = "";
    String initialEmail = "";
    String initialUserName = "";
    String initialType = "student";

    if (state is ProfileLoaded) {
      initialName = state.user.name;
      initialEmail = state.user.email;
      initialUserName = state.user.userName; // Usando userName de tu Entidad
      initialType = state.user.type;
    }

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    _userNameController = TextEditingController(text: initialUserName);
    _passwordController = TextEditingController();
    _selectedType = initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    // Armamos el Map con las llaves que espera tu API (PATCH /user/profile/)
    // Usamos los nombres de los controllers definidos arriba
    final Map<String, dynamic> updateData = {
      "name": _nameController.text.trim(),
      "username": _userNameController.text.trim(), // La API espera 'username'
      "email": _emailController.text.trim(),
    };

    if (_passwordController.text.isNotEmpty) {
      updateData["password"] = _passwordController.text;
    }

    // Disparamos el evento al Bloc pasando el updateData
    context.read<ProfileBloc>().add(ProfileUpdateInfo(updateData));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perfil actualizado correctamente")),
          );
          Navigator.pop(context); // Regresa a la pantalla anterior
        }
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${state.message}"), 
              backgroundColor: Colors.redAccent
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 30),
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
                      _buildInputField(_userNameController, Icons.alternate_email),

                      _buildLabel("New Password"),
                      _buildInputField(_passwordController, Icons.lock_outline, obscureText: true),


                      const SizedBox(height: 40),

                      // Botón con manejo de estado Loading
                      _buildSubmitButton(state),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widgets de soporte (manteniendo tu estilo visual) ---

  Widget _buildSubmitButton(ProfileState state) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
      ),
      child: ElevatedButton(
        onPressed: state is ProfileLoading ? null : _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: state is ProfileLoading
            ? const SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : const Text(
                "Complete",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // Header decorativo original
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "Edit Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 55, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 5),
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
  );

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

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Radio<String>(
          value: "student",
          groupValue: _selectedType,
          activeColor: const Color(0xFF9D50BB),
          onChanged: (v) => setState(() => _selectedType = v!),
        ),
        const Text("Student"),
        const SizedBox(width: 20),
        Radio<String>(
          value: "teacher",
          groupValue: _selectedType,
          activeColor: const Color(0xFF9D50BB),
          onChanged: (v) => setState(() => _selectedType = v!),
        ),
        const Text("Teacher"),
      ],
    );
  }
}


// Esta clase debe ir al final del archivo, fuera de cualquier otra clase
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(
        size.width * 0.8, size.height - 90, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}