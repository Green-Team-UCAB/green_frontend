import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';

// Importamos el BLoC de la Épica 7 (Biblioteca) para reutilizar la lógica de Favoritos
import '../../presentation/bloc/library_bloc.dart';
import '../../domain/entities/kahoot_summary.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/screens/single_player_game.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_event.dart';

import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';


import 'package:green_frontend/core/network/api_client.dart'; 
import 'package:green_frontend/core/storage/token_storage.dart';  
import 'package:green_frontend/features/multiplayer/presentation/screens/multiplayer_lobby_screen.dart';

class QuizDetailPage extends StatelessWidget {
  final dynamic quiz;
  final bool isAdmin; // ✅ Define si muestras controles de edición o solo jugar

  const QuizDetailPage({
    super.key,
    required this.quiz,
    this.isAdmin = false, // Por defecto es vista de jugador (Discovery)
  });

  @override
  Widget build(BuildContext context) {
    // Inyectamos el LibraryBloc para manejar el favorito
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<LibraryBloc>()..add(LoadLibraryDataEvent()),
        ),
        BlocProvider(
          create: (_) => sl<GameBloc>(),
        ),
      ],
      child: _QuizDetailView(quiz: quiz, isAdmin: isAdmin),
    );
  }
}

class _QuizDetailView extends StatelessWidget {
  final dynamic quiz;
  final bool isAdmin;

  const _QuizDetailView({required this.quiz, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // 🔍 LÓGICA DE EXTRACCIÓN DE DATOS (Soporta JSON y Entidad)
    // ============================================================
    final String quizId = (quiz is KahootSummary) ? quiz.id : quiz['id'];

    final String title =
        (quiz is KahootSummary) ? quiz.title : (quiz['title'] ?? 'Sin título');

    final String description = (quiz is KahootSummary)
        ? (quiz.description ?? '')
        : (quiz['description'] ?? 'Sin descripción disponible.');

    final String? imageUrl =
        (quiz is KahootSummary) ? quiz.coverImageId : quiz['coverImageId'];

    final int playCount =
        (quiz is KahootSummary) ? quiz.playCount : (quiz['playCount'] ?? 0);

    // --- CORRECCIÓN CRÍTICA DEL AUTOR ---
    String authorName = 'Desconocido';

    if (quiz is KahootSummary) {
      // Caso 1: Viene de la Biblioteca (Entidad ya procesada)
      authorName = quiz.authorName ?? 'Desconocido';
    } else if (quiz is Map) {
      // Caso 2: Viene de Discovery (JSON Crudo)
      // La estructura es "author": { "name": "User..." }
      if (quiz['author'] != null && quiz['author'] is Map) {
        authorName = quiz['author']['name'] ?? 'Desconocido';
      } else if (quiz['authorName'] != null) {
        // Fallback por si acaso viniera plano
        authorName = quiz['authorName'];
      }
    }
    // ============================================================

    // Datos mock para completar la UI si faltan en el modelo
    final int questionsCount = (quiz is Map && quiz['questionsCount'] != null)
        ? quiz['questionsCount']
        : 10;
    final String category = (quiz is Map && quiz['category'] != null)
        ? quiz['category']
        : "General";

    return BlocListener<MultiplayerBloc, MultiplayerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == MultiplayerStatus.inLobby) {
          // Si el estado cambia a inLobby, disparamos la navegación
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
          // --- APP BAR CON IMAGEN Y FAVORITO ---
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: [
              BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  bool isFavorite = false;
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
                  if (imageUrl != null && imageUrl.startsWith('http'))
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

          // --- CONTENIDO DEL BODY ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges y Stats
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

                  // Título
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Autor
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
                      // Nombre del Autor (Extraído dinámicamente)
                      Text(
                        "Creado por $authorName",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      // Badge "Tú" solo si es Admin (dueño)
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Tú",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Descripción
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

                  // Caja de Estadísticas
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // =========================================================
      // 🎮 BARRA INFERIOR ADAPTATIVA
      // =========================================================
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
        child: isAdmin
            ? _buildAdminControls(context)
            : _buildPlayerControls(context, quizId),
      ),
    ),
    );
  }

  // --- MODO JUGADOR ---
  Widget _buildPlayerControls(BuildContext context, String quizId) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        context.read<GameBloc>().add(StartGame(quizId));

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
    );
  }

Widget _buildAdminControls(BuildContext context) {
  // Se obtiene el ID del quiz
  final String quizId = (quiz is KahootSummary) ? quiz.id : quiz['id'];

  return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- BOTÓN MULTIJUGADOR (HOST) ---
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
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
            //  Si el token falló, mandamos al login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sesión inválida. Por favor ingresa de nuevo.")),
            );
             Navigator.pushReplacementNamed(context, '/login');
            }
          },
          // Si está cargando,se muestra un spinner 
          icon: context.watch<MultiplayerBloc>().state.status == MultiplayerStatus.connecting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.qr_code_2, size: 28),
          label: const Text(
            "Generar PIN y Código QR",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        
        const SizedBox(height: 12),

        // --- BOTÓN EDITAR  ---
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            side: const BorderSide(color: Colors.deepPurple, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            // Lógica de edición
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text(
            "Editar Quiz",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
