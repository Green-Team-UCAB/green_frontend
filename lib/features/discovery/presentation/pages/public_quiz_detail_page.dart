import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';

// Importamos el BLoC de la Épica 7 (Biblioteca) para reutilizar la lógica de Favoritos
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/domain/entities/kahoot_summary.dart';

class PublicQuizDetailPage extends StatelessWidget {
  final dynamic quiz;

  const PublicQuizDetailPage({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    // 1. WRAPPER: Inyectamos el LibraryBloc y cargamos los datos al entrar.
    // Esto permite saber inmediatamente si el quiz ya era favorito o no.
    return BlocProvider(
      create: (_) => sl<LibraryBloc>()..add(LoadLibraryDataEvent()),
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
    final authorName = quiz['author'] != null
        ? quiz['author']['name']
        : 'Desconocido';
    final playCount = quiz['playCount'] ?? 0;
    final questionsCount = quiz['questionsCount'] ?? 0;
    final imageUrl = quiz['coverImageId'];
    final category = quiz['category'] ?? 'General';

    return Scaffold(
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Aquí conectarás la Épica 5 (Jugar) en el futuro
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Funcionalidad 'Jugar' próximamente..."),
              ),
            );
          },
          child: const Text(
            "JUGAR AHORA",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
