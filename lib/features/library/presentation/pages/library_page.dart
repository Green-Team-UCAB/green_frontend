import 'package:flutter/material.dart';

// 1. Importamos la página de Kahoots Personales (Épica 7)
import 'personal_kahoots_page.dart';

// 2. Importamos la página de Grupos (Épica 8)
import '../../../groups/presentation/pages/groups_list_page.dart';

// 3. ✅ NUEVO IMPORT: Importamos tu página de Reportes (Épica 10)
import '../../../reports/presentation/pages/reports_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Biblioteca General',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // --- SECCIÓN 1: TU CONTENIDO ---
          const _SectionLabel("TU CONTENIDO"),
          _MenuCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalKahootsPage()),
              );
            },
            icon: Icons.person_outline,
            color: Colors.deepPurple,
            title: "Mis Kahoots",
            subtitle: "Creados, Favoritos e Historial",
          ),

          const SizedBox(height: 20),

          // --- SECCIÓN 2: COMUNIDAD ---
          const _SectionLabel("COMUNIDAD"),
          _MenuCard(
            onTap: () {
              // Navegación a Grupos
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupsListPage()),
              );
            },
            icon: Icons.groups_outlined,
            color: Colors.orange,
            title: "Grupos de Estudio",
            subtitle: "Aulas y colaboración",
          ),

          const SizedBox(height: 20),

          // --- SECCIÓN 3: RENDIMIENTO ---
          const _SectionLabel("RENDIMIENTO"),
          _MenuCard(
            onTap: () {
              // ✅ CAMBIO AQUÍ: Navegación real a ReportsPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsPage()),
              );
            },
            icon: Icons.bar_chart_rounded,
            color: Colors.blueAccent,
            title: "Informes y Estadísticas",
            subtitle: "Resultados de tus juegos",
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS DE DISEÑO (Sin cambios)
// -----------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _MenuCard({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
