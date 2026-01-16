import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';

// Importamos el BLoC de la Épica 7 (Biblioteca) para reutilizar la lógica de Favoritos
import '../../../library/presentation/bloc/library_bloc.dart';

import 'package:green_frontend/features/single_player/presentation/bloc/game_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/screens/single_player_game.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_event.dart';

import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/core/network/api_client.dart';
import 'package:green_frontend/core/storage/token_storage.dart';
import 'package:green_frontend/features/multiplayer/presentation/screens/multiplayer_lobby_screen.dart';

class PublicQuizDetailPage extends StatelessWidget {
  final dynamic quiz;

  const PublicQuizDetailPage({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    // 1. WRAPPER: Inyectamos el LibraryBloc y cargamos los datos al entrar.
    // Esto permite saber inmediatamente si el quiz ya era favorito o no.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<LibraryBloc>()..add(LoadLibraryDataEvent()),
        ),
        BlocProvider(
          create: (_) => sl<GameBloc>(),
        ),
      ],
      child: _QuizDetailView(quiz: quiz),
    );
  }
}

class _QuizDetailView extends StatelessWidget {
  final dynamic quiz;
  const _QuizDetailView({required this.quiz});

  @override
  Widget build(BuildContext context) {
    // Extracción de datos (igual que tenías)
    final quizId = quiz['id'];
    final title = quiz['title'] ?? 'Sin título';
    final description = quiz['description'] ?? 'Sin descripción disponible.';
    final authorName =
        quiz['author'] != null ? quiz['author']['name'] : 'Desconocido';
    final playCount = quiz['playCount'] ?? 0;
    final questionsCount = quiz['questionsCount'] ?? 0;
    final imageUrl = quiz['coverImageId'];
    final category = quiz['category'] ?? 'General';

    return BlocListener<MultiplayerBloc, MultiplayerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == MultiplayerStatus.inLobby) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<MultiplayerBloc>(),
                child: const MultiplayerLobbyScreen(),
              ),
            ),
          );
        }

        if (state.status == MultiplayerStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure?.message ?? "Error")),
          );
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Appbar con Imagen Grande (Efecto Parallax) + BOTÓN FAVORITO
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: [
              // ==================================================
              // ❤️ AQUÍ ESTÁ LA NUEVA FUNCIONALIDAD DE FAVORITOS
              // ==================================================
              BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  bool isFavorite = false;

                  // Buscamos si el ID de este quiz está en la lista de favoritos cargada
                  if (state is LibraryLoaded) {
                    isFavorite = state.favorites.any((k) => k.id == quizId);
                  }

                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey[800],
                      ),
                      onPressed: () {
                        // Disparamos el evento al BLoC
                        context.read<LibraryBloc>().add(
                              ToggleFavoriteInLibraryEvent(
                                kahootId: quizId,
                                isCurrentlyFavorite: isFavorite,
                              ),
                            );
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(""),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null &&
                      imageUrl.toString().startsWith('http'))
                    Image.network(imageUrl, fit: BoxFit.cover)
                  else
                    Container(
                      color: Colors.deepPurple.shade100,
                      child: const Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent],
                        stops: [0.0, 0.3],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Contenido (Igual que tenías)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(category),
                        backgroundColor: Colors.deepPurple.withValues(
                          alpha: 0.1,
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.play_circle_outline,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$playCount jugadas",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Creado por $authorName",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Descripción",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Información extra
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(Icons.quiz, "$questionsCount", "Preguntas"),
                        _buildStat(Icons.timer, "---", "Minutos"),
                        _buildStat(Icons.star, "4.5", "Rating"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: _buildAdminControls(context),
      ),
    ),
    );
  }

  Widget _buildAdminControls(BuildContext context) {
    // Se obtiene el ID del quiz
    final String quizId = quiz['id'];

    // Los Kahoots de Discovery ya son públicos por defecto
    // Solo verificamos draft si el campo status existe explícitamente
    final String? kahootStatus = quiz['status'] as String?;

    // Verificar si es un borrador (solo si el campo status viene explícitamente como draft/borrador)
    final bool isDraft = kahootStatus != null &&
        (kahootStatus.toLowerCase() == 'draft' ||
            kahootStatus.toLowerCase() == 'borrador');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- BOTÓN MULTIJUGADOR (HOST) ---
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDraft ? Colors.grey : Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isDraft
              ? () {
                  // Mostrar diálogo de error para borradores
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("No disponible"),
                      content: const Text(
                        "Para crear una sesión multijugador (PIN y Código QR), "
                        "primero debes publicar tu Kahoot. "
                        "Los borradores no pueden usarse para partidas en línea.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Entendido"),
                        ),
                      ],
                    ),
                  );
                }
              : () async {
                  context.read<MultiplayerBloc>().add(OnResetMultiplayer());
                  String? token = sl<ApiClient>().authToken;
                  token ??= await TokenStorage.getToken();
                  if (!context.mounted) return;
                  if (token != null && token.isNotEmpty) {
                    context.read<MultiplayerBloc>().add(
                      OnCreateSessionStarted(
                        kahootId: quizId,
                        jwt: token,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Sesión inválida. Por favor ingresa de nuevo.")),
                    );
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
          icon: !isDraft &&
                  context.watch<MultiplayerBloc>().state.status ==
                      MultiplayerStatus.connecting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.qr_code_2, size: 28),
          label: Text(
            isDraft ? "Publicar para generar PIN y QR" : "Generar PIN y Código QR",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        // --- BOTÓN JUGAR SOLO ---
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            context.read<GameBloc>().add(StartGame(quiz['id']));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<GameBloc>(),
                  child: const SinglePlayerGameScreen(),
                ),
              ),
            );
          },
          child: const Text(
            "JUGAR AHORA",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
