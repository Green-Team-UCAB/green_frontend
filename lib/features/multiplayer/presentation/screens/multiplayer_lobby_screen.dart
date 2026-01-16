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
          backgroundColor: const Color.fromARGB(255, 225, 222, 228),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ✅ QR pequeño arriba del PIN
                if (isHost && state.pin != null)
                  SizedBox(
                    height: 100,
                    child: QrImageView(
                      data: state.pin!.value,
                      version: QrVersions.auto,
                      size: 100.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color.fromARGB(255, 142, 139, 146),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ✅ PIN grande
                const Text("PIN del juego:",
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
                Text(pin,
                    style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Colors.white)),

                const SizedBox(height: 20),

                // ✅ Título de jugadores
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jugadores",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text("${players.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Lista de jugadores
                Expanded(
                  child: players.isEmpty
                      ? const Center(
                          child: Text("Esperando a los jugadores...",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20)),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(player.nickname,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                ),

                // ✅ Botón solo para el host
                if (isHost)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      onPressed: () {
                        context.read<MultiplayerBloc>().add(OnStartGame());
                      },
                      child: const Text("¡EMPEZAR!",
                          style:
                              TextStyle(fontSize: 24, color: Colors.white)),
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