import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/auth/presentation/screens/edit_profile.dart';
import 'package:green_frontend/features/user/presentation/profile_bloc.dart';
import 'package:green_frontend/features/user/presentation/profile_event.dart';
import 'package:green_frontend/features/user/presentation/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Disparamos la carga de datos al iniciar la pantalla
    context.read<ProfileBloc>().add(ProfileGetInfo());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // 1. Estado de carga
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Estado de Error
          if (state is ProfileFailure) {
            return Center(child: Text("Error: ${state.message}"));
          }

          // 3. Estado con datos (Cargamos tu UI con la info del Bloc)
          if (state is ProfileLoaded) {
            final user = state.user;

            return Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Banner
                    ClipPath(
                      clipper: HeaderClipper(),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),

                    // Imagen del avatar dinámica
                    Positioned(
                      top: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(blue: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: const Color(0xFFF3E5F5),
                          backgroundImage: (user.avatarAssetUrl != null && user.avatarAssetUrl!.isNotEmpty)
                              ? NetworkImage(user.avatarAssetUrl!)
                              : null,
                          child: (user.avatarAssetUrl == null || user.avatarAssetUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 60, color: Color(0xFF6E48AA))
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),

                // Espacio para compensar el avatar
                const SizedBox(height: 70),

                // NOMBRE DINÁMICO
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                // ROL DINÁMICO
                Text(
                  user.type,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 30),

                // Opciones de perfil (Tus mismos botones)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        _buildOptionTile(
                          icon: Icons.edit_note_rounded,
                          title: "Editar Perfil",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildOptionTile(
                          icon: Icons.logout_rounded,
                          title: "Cerrar Sesión",
                          color: Colors.redAccent,
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- Mantenemos tus métodos originales ---

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cerrar Sesión"),
        content: const Text("Está seguro que desea cerrar sesión?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // Aquí podrías agregar la lógica de logout real si lo deseas
              Navigator.pop(ctx);
            },
            child: const Text("Cerrar Sesión",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}