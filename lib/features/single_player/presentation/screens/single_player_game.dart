import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_state.dart';

class SinglePlayerGameScreen extends StatelessWidget {
  const SinglePlayerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Juego en progreso")),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GameInProgress) {
            return Center(
              child: Text("Intento iniciado: ${state.attempt.attemptId}"),
            );
          } else if (state is GameError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Esperando acción..."));
        },
      ),
    );
  }
}
