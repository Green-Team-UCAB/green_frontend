import 'package:flutter/material.dart';
import 'package:green_frontend/features/auth/presentation/screens/edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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

              // imagen del avatar
              Positioned(
                top: 160,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xFFF3E5F5),
                    child:
                        Icon(Icons.person, size: 60, color: Color(0xFF6E48AA)),
                  ),
                ),
              ),
            ],
          ),

          // Espacio para compensar el avatar que sobresale
          const SizedBox(height: 70),

          const Text(
            "Carlos David",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const Text(
            "Student",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 30),

          // Opciones de perfil
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
      ),
    );
  }

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
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar Sesión",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Clipper actualizado para una curva simétrica y elegante
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    // Crea una curva cóncava hacia arriba en el centro
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
