import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';

class MultiplayerResultsScreen extends StatelessWidget {
  const MultiplayerResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerBloc, MultiplayerState>(
      listener: (context, state) {
        // IMPORTANTE: Si llega una nueva pregunta, volvemos a la pantalla de juego
        if (state.status == MultiplayerStatus.inQuestion) {
          Navigator.pushReplacementNamed(context, '/multiplayer_game'); 
          // O Navigator.pop(context) si no usaste pushReplacement antes
        }
        
        // Si el juego termina, vamos al podio
        if (state.status == MultiplayerStatus.gameEnded) {
          Navigator.pushReplacementNamed(context, '/multiplayer_podium');
        }
      },
      builder: (context, state) {
        final bool isHost = state.role == ClientRole.host;
        
        // Si es Host, mostramos una pantalla de "Estadísticas" o "Ranking"
        if (isHost) {
          return _buildHostResultsView(context, state);
        }

        // Si es Jugador, mostramos su feedback personal (Tu código actual)
        return _buildPlayerResultsView(context, state);
      },
    );
  }

  // --- VISTA PARA EL JUGADOR (Tu código mejorado) ---
  Widget _buildPlayerResultsView(BuildContext context, MultiplayerState state) {
    final result = state.lastQuestionResult;
    final bool isCorrect = result?.isCorrect ?? false;

    return Scaffold(
      backgroundColor: isCorrect ? const Color(0xFF26890C) : const Color(0xFFE21B3C),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCorrect ? "¡CORRECTO!" : "¡INCORRECTO!",
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: Colors.white, size: 120),
            const SizedBox(height: 40),
            
            // Puntos ganados
            _PointsBadge(points: result?.pointsEarned ?? 0),
            
            const SizedBox(height: 20),
            Text(
              "Puntuación total: ${result?.totalScore ?? 0}",
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text("Espera al anfitrión...", style: TextStyle(color: Colors.white60)),
            ),
          ],
        ),
      ),
    );
  }

  // --- VISTA PARA EL HOST (Resumen de la pregunta) ---
  Widget _buildHostResultsView(BuildContext context, MultiplayerState state) {
  final result = state.lastHostResult;
  // Usamos tu mapa de distribución (ID de respuesta -> cantidad de votos)
  final distribution = result?.distributionTop3 ?? {};
  // Usamos tu lista de ranking
  final ranking = result?.leaderboard ?? [];

  return Scaffold(
    backgroundColor: const Color(0xFF46178F),
    appBar: AppBar(
      title: Text("Pregunta ${result?.currentQuestion} de ${result?.totalQuestions}"),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Column(
      children: [
        const Text(
          "Resultados",
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        
        // 1. Gráfico simple de barras para la distribución
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: distribution.entries.map((entry) {
              return Column(
                children: [
                  Text("${entry.value}", style: const TextStyle(color: Colors.white)),
                  Container(
                    width: 40,
                    height: (entry.value * 20.0) + 10, // Altura proporcional a los votos
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 8),
                  Text("Opción ${entry.key}", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              );
            }).toList(),
          ),
        ),

        const Divider(color: Colors.white24),

        // 2. Leaderboard (Ranking en tiempo real)
        const Text("TOP 5", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: ranking.take(5).length, // Solo mostramos los top 5
            itemBuilder: (context, index) {
              final entry = ranking[index];
              return Card(
                color: Colors.white.withOpacity(0.1),
                child: ListTile(
                  leading: Text("#${index + 1}", style: const TextStyle(color: Colors.white)),
                  title: Text(entry.nickname, style: const TextStyle(color: Colors.white)),
                  trailing: Text("${entry.score} pts", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
        
        _buildFooter(context, state),
      ],
    ),
  );
}

  Widget _buildFooter(BuildContext context, MultiplayerState state) {
  final bool isLast = state.lastHostResult?.isLastSlide ?? false;

  if (state.role == ClientRole.host) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLast ? Colors.amber : Colors.white, // Color especial si es la última
          minimumSize: const Size(double.infinity, 60),
        ),
        onPressed: () => context.read<MultiplayerBloc>().add(OnNextPhase()),
        child: Text(
          isLast ? "VER PODIO FINAL" : "SIGUIENTE PREGUNTA", 
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
  return const SizedBox.shrink();
}
}

// Widget auxiliar para los puntos
class _PointsBadge extends StatelessWidget {
  final int points;
  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(50)),
      child: Text("+$points pts", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}