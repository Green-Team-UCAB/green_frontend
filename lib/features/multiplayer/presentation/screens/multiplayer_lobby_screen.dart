import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MultiplayerLobbyScreen extends StatelessWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerBloc, MultiplayerState>(
      listener: (context, state) {
        if (state.status == MultiplayerStatus.inQuestion) {
          Navigator.pushNamed(context, '/multiplayer_game');
        }
        if (state.status == MultiplayerStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure?.message ?? 'Error')),
          );
        }
      },
      builder: (context, state) {
        final isHost = state.role == ClientRole.host;
        final pin = state.pin?.value ?? "--- ---";
        final players = state.lobby?.players ?? [];

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                //  QR pequeño arriba del PIN
                if (isHost && state.pin != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: state.pin!.value,
                      version: QrVersions.auto,
                      size: 80.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.deepPurple,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // PIN grande
                const Text("PIN del juego:",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                Text(pin,
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Colors.deepPurple)),

                const SizedBox(height: 30),

                //  Título de jugadores
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jugadores",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("${players.length}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de jugadores
                Expanded(
                  child: players.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text("Esperando a los jugadores...",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 18)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withValues(alpha: 0.1),
                                border: Border.all(
                                    color: Colors.deepPurple.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(player.nickname,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Botón solo para el host
                if (isHost)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        context.read<MultiplayerBloc>().add(OnStartGame());
                      },
                      child: const Text("¡EMPEZAR!",
                          style:
                              TextStyle(fontSize: 22, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}