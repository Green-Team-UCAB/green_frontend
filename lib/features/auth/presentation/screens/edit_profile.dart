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
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _userNameController;
  
  // Controladores para el cambio de contraseña según API
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    
    String initialName = "";
    String initialEmail = "";
    String initialUserName = "";

    if (state is ProfileLoaded) {
      initialName = state.user.name;
      initialEmail = state.user.email;
      initialUserName = state.user.userName;
    }

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    _userNameController = TextEditingController(text: initialUserName);

    // Listener para validar contraseñas en tiempo real
    _newPasswordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      _passwordsMatch = _newPasswordController.text.isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSave() {
    final Map<String, dynamic> updateData = {
      "name": _nameController.text.trim(),
      "username": _userNameController.text.trim(),
      "email": _emailController.text.trim(),
    };

    // Si el usuario intentó escribir una nueva contraseña
    if (_newPasswordController.text.isNotEmpty) {
      if (!_passwordsMatch) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Las contraseñas no coinciden")),
        );
        return;
      }
      if (_currentPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debes ingresar tu contraseña actual")),
        );
        return;
      }

      // Añadimos los campos exactos del JSON de tu API
      updateData["currentPassword"] = _currentPasswordController.text;
      updateData["newPassword"] = _newPasswordController.text;
      updateData["confirmNewPassword"] = _confirmPasswordController.text;
    }

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
          Navigator.pop(context);
        }
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.message}"), backgroundColor: Colors.redAccent),
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
                      _buildLabel("Información Personal"),
                      _buildInputField(_nameController, Icons.person_outline, "Full Name"),
                      _buildInputField(_emailController, Icons.email_outlined, "Email Address"),
                      _buildInputField(_userNameController, Icons.alternate_email, "Username"),

                      const SizedBox(height: 20),
                      _buildLabel("Seguridad (Opcional)"),
                      
                      // Password Actual
                      _buildInputField(
                        _currentPasswordController, 
                        Icons.lock_open_outlined, 
                        "Current Password", 
                        obscureText: true
                      ),
                      
                      // Password Nueva con Check Verde
                      _buildInputField(
                        _newPasswordController, 
                        Icons.lock_outline, 
                        "New Password", 
                        obscureText: true
                      ),
                      
                      // Confirmación con Check Verde Dinámico
                      _buildInputField(
                        _confirmPasswordController, 
                        _passwordsMatch ? Icons.check_circle : Icons.lock_reset_outlined, 
                        "Confirm New Password", 
                        obscureText: true,
                        iconColor: _passwordsMatch ? Colors.green : const Color(0xFF9D50BB)
                      ),

                      const SizedBox(height: 40),
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

  // --- Widgets Refactorizados ---

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
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

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
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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
    padding: const EdgeInsets.only(top: 15, bottom: 5),
    child: Text(text, style: const TextStyle(color: Color(0xFF6E48AA), fontSize: 15, fontWeight: FontWeight.bold)),
  );

  Widget _buildInputField(
    TextEditingController controller, 
    IconData icon, 
    String hint, 
    {bool obscureText = false, Color? iconColor}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1C4E9))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6E48AA), width: 2)),
          suffixIcon: Icon(icon, color: iconColor ?? const Color(0xFF9D50BB), size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

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