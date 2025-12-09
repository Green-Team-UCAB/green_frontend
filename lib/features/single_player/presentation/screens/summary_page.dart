import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';
import 'package:green_frontend/features/single_player/presentation/screens/game_page.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/home_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/nav_bar_selection_screen.dart';


class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.summary == null) {
            return const Center(child: Text('No hay resumen disponible'));
          }

          final summary = controller.summary!;
          final kahoot = controller.preview;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F5F5),
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Título principal
                    Text(
                      'Nice Work',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tarjeta de puntuación
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Puntuación principal
                          Text(
                            'You Earned',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${summary.finalScore}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'pts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Barra divisoria
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            height: 1,
                          ),
                          const SizedBox(height: 24),

                          // Estadísticas detalladas
                          _buildStatRow(
                            icon: Icons.check_circle,
                            iconColor: Colors.green,
                            label: 'Correct Answers',
                            value: '${summary.totalCorrectAnswers}/${summary.totalQuestions}',
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            icon: Icons.percent,
                            iconColor: Colors.blue,
                            label: 'Accuracy',
                            value: '${_calculateAccuracy(summary)}%',
                          ),
                          if (kahoot != null) ...[
                            const SizedBox(height: 16),
                            _buildStatRow(
                              icon: Icons.quiz,
                              iconColor: Colors.purple,
                              label: 'Kahoot',
                              value: kahoot.title,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botones de acción
                    Column(
                      children: [
                        // Botón "Home" (volver a pantalla principal)
                        _buildActionButton(
                          text: 'Volver a Home',
                          icon: Icons.home,
                          color: Colors.blue,
                          onPressed: () => _goToHomeScreen(context, controller),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botón "Play Again" (repetir el mismo kahoot)
                        _buildActionButton(
                          text: 'Jugar de nuevo',
                          icon: Icons.replay,
                          color: Colors.purple,
                          onPressed: () => _repeatKahoot(context, controller),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Icono decorativo
                    const Spacer(),
                    Icon(
                      Icons.celebration,
                      size: 60,
                      color: Colors.amber.withValues(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateAccuracy(Summary summary) {
    if (summary.totalQuestions == 0) return '0.0';
    final accuracy = (summary.totalCorrectAnswers / summary.totalQuestions) * 100;
    return accuracy.toStringAsFixed(1);
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToHomeScreen(BuildContext context, GameController controller) {
    // Resetear completamente el controller
    controller.fullReset();
    
    // Navegar directamente a la pantalla principal
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => NavBarSelectionScreen(), // O KahootLibraryScreen si esa es tu home
      ),
      (route) => false, // Elimina todas las rutas anteriores
    );
  }

  void _repeatKahoot(BuildContext context, GameController controller) {
    final kahootId = controller.preview?.id ?? controller.lastKahootId;
    
    if (kahootId != null && kahootId.isNotEmpty) {
      // Resetear el controller para un nuevo juego
      controller.reset();
      
      // Iniciar nuevo intento directamente
      // Usamos pushReplacement para reemplazar el SummaryPage por GamePage
      controller.startNewAttempt(kahootId, context);
    } else {
      // Si no hay kahootId, ir al home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede encontrar el kahoot')),
      );
      _goToHomeScreen(context, controller);
    }
  }
}