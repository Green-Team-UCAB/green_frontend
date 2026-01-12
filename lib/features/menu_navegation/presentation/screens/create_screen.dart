import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/presentation/screens/create_kahoot_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/development.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos Scaffold para asegurar el contexto correcto del tema
      body: Center(
        child: SingleChildScrollView(
          // Para evitar overflow en pantallas pequeñas
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Creación del Kahoot',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // --- BOTÓN 1: LIENZO BLANCO ---
              _CreateOptionButton(
                icon: Icons.create_outlined,
                title: 'Lienzo Blanco',
                subtitle: 'Crea kahoot desde 0',
                color: Colors.blue,
                onPressed: () {
                  // Limpiamos el provider para empezar vacio
                  context.read<KahootProvider>().clear();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateKahootScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // --- BOTÓN 2: GENERAR CON IA (NUEVO) ---
              _CreateOptionButton(
                icon: Icons.auto_awesome, // Icono mágico
                title: 'Generar con IA',
                subtitle: 'Crea un quiz completo mágicamente',
                color: Colors.deepPurple, // Color distintivo para IA
                onPressed: () => _showAiInputDialog(context),
              ),

              const SizedBox(height: 20),

              // --- BOTÓN 3: PLANTILLA ---
              _CreateOptionButton(
                icon: Icons.layers_outlined,
                title: 'Plantilla',
                subtitle: 'Usa una estructura existente',
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DesarrolloPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧠 LÓGICA DE IA: Diálogo + Llamada al Provider
  void _showAiInputDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.deepPurple),
            SizedBox(width: 10),
            Text("Quiz Mágico"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Escribe un tema y la Inteligencia Artificial creará el título, la descripción y las preguntas por ti.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Ej: Capitales de Europa, Química Orgánica...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                // 1. Cerrar el diálogo de entrada
                Navigator.pop(dialogContext);

                // 2. Ejecutar la lógica de generación con Feedback de carga
                await _generateAndNavigate(context, controller.text);
              }
            },
            icon: const Icon(Icons.stars, size: 18),
            label: const Text("Generar"),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndNavigate(BuildContext context, String topic) async {
    // Mostramos un diálogo de carga bloqueante
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 16),
                Text(
                  "La IA está pensando...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Creando preguntas y respuestas",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 1. Limpiamos el estado anterior
      final provider = context.read<KahootProvider>();
      provider.clear();

      // 2. Llamamos a la IA (Esto llena el _currentKahoot en el provider)
      await provider.generateWithAi(topic);

      // 3. Cerramos el diálogo de carga
      if (context.mounted) Navigator.pop(context);

      // 4. Verificamos si hubo error
      if (provider.error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // 5. ¡ÉXITO! Navegamos a la pantalla de edición
        // Como el provider ya tiene los datos, la pantalla los mostrará automáticamente
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateKahootScreen()),
          );
        }
      }
    } catch (e) {
      // Manejo de errores de red o imprevistos
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error inesperado: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Widget auxiliar para no repetir código de estilo en los botones
class _CreateOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final Color color;

  const _CreateOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
