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
          Navigator.pushNamed(context, '/multplayer_screen');
        }
        if (state.status == MultiplayerStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure?.message ?? 'Error')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF46178F), 
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(state), // Aquí estará el QR y el PIN
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jugadores", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text("${state.lobby?.players.length ?? 0}", 
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildPlayerList(state)),
                _buildFooter(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  // Muestra el PIN y el título
  Widget _buildHeader(MultiplayerState state) {
    final bool isHost = state.role == ClientRole.host;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      width: double.infinity,
      child: Column(
        children: [
          Text(isHost ? "¡Únete a la partida!" : "¡Ya estás dentro!", 
          style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        
        // CÓDIGO QR: Solo si es Host
        if (isHost)
          state.pin != null 
            ? _buildQRCode(state.pin!.value) // Tu código de QrImageView
            : const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
        else
          // Si es jugador, mostramos un icono de éxito
          const SizedBox(
            height: 180, 
            child: Icon(Icons.check_circle_outline, color: Colors.green, size: 100)
          ),
          

          const SizedBox(height: 12),
          const Text("PIN del juego:", style: TextStyle(fontSize: 14, color: Colors.black54)),
          Text(
            state.pin?.value ?? "--- ---",
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 4),
          ),
        ],
      ),
    );
  }

  // Lista de jugadores en tiempo real (Pág 58: event player_joined)
  Widget _buildPlayerList(MultiplayerState state) {
    final players = state.lobby?.players ?? [];
    
    if (players.isEmpty) {
      return const Center(
        child: Text("Esperando a los jugadores...", 
          style: TextStyle(color: Colors.white, fontSize: 20)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: players.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              players[index].nickname,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // Botón de acción (Solo para el Host)
  Widget _buildFooter(BuildContext context, MultiplayerState state) {
    // Si no es host, no mostramos el botón de inicio
    if (state.role != ClientRole.host) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Text("¡Estás dentro! Esperando a que comience la partida...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 60),
        ),
        onPressed: () {
          context.read<MultiplayerBloc>().add(OnStartGame());
        },
        child: const Text("¡EMPEZAR!", style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }

  Widget _buildQRCode(String pinValue) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(12),
    ),
    child: QrImageView(
      data: pinValue,
      version: QrVersions.auto,
      size: 180.0,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square, 
        color: Color(0xFF46178F), 
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle, 
        color: Colors.black,
      ),
    ),
  );
}
}