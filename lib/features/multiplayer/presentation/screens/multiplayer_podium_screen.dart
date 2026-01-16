import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/leaderboard.dart';

class MultiplayerPodiumScreen extends StatelessWidget {
  const MultiplayerPodiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerBloc, MultiplayerState>(
      builder: (context, state) {
        final bool isHost = state.role == ClientRole.host;
        final summary = state.podium;

        return Scaffold(
          backgroundColor: const Color(0xFF46178F),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  isHost ? "RESULTADOS FINALES" : "¡PARTIDA TERMINADA!",
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.w900
                  ),
                ),
                
                const Spacer(),

                // Lógica basada en tu entidad Summary
                if (isHost)
                  _buildHostPodio(summary?.finalPodium ?? [])
                else
                  _buildPlayerFinalScore(
                    rank: summary?.rank ?? 0,
                    score: summary?.totalScore ?? 0,
                    isWinner: summary?.isWinner ?? false,
                  ),

                const Spacer(),
                
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      context.read<MultiplayerBloc>().add(OnResetMultiplayer());
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      "FINALIZAR", 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- VISTA HOST: Usa finalPodium (List<LeaderboardEntry>) ---
  Widget _buildHostPodio(List<LeaderboardEntry> podium) {
    // Buscamos por el campo 'rank' de tu LeaderboardEntry
    final first = podium.firstWhere((e) => e.rank == 1, orElse: () => podium[0]);
    final second = podium.length > 1 ? podium.firstWhere((e) => e.rank == 2, orElse: () => podium[1]) : null;
    final third = podium.length > 2 ? podium.firstWhere((e) => e.rank == 3, orElse: () => podium[2]) : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          _PodiumColumn(
            nickname: second.nickname,
            score: second.score,
            height: 140,
            color: const Color(0xFFC0C0C0),
            position: "2nd",
          ),
        _PodiumColumn(
          nickname: first.nickname,
          score: first.score,
          height: 200,
          color: const Color(0xFFFFD700),
          position: "1st",
          isWinner: true,
        ),
        if (third != null)
          _PodiumColumn(
            nickname: third.nickname,
            score: third.score,
            height: 100,
            color: const Color(0xFFCD7F32),
            position: "3rd",
          ),
      ],
    );
  }

  // --- VISTA JUGADOR: Usa rank y totalScore del Summary ---
  Widget _buildPlayerFinalScore({required int rank, required int score, required bool isWinner}) {
    return Column(
      children: [
        Icon(
          isWinner ? Icons.emoji_events : Icons.stars, 
          size: 100, 
          color: isWinner ? Colors.amber : Colors.white54
        ),
        const SizedBox(height: 20),
        const Text("Tu posición:", style: TextStyle(color: Colors.white70, fontSize: 18)),
        Text(
          "#$rank",
          style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          "$score PUNTOS",
          style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final String nickname;
  final int score;
  final double height;
  final Color color;
  final String position;
  final bool isWinner;

  const _PodiumColumn({
    required this.nickname,
    required this.score,
    required this.height,
    required this.color,
    required this.position,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          nickname,
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: isWinner ? 18 : 14
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              position,
              style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w900, fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }
}