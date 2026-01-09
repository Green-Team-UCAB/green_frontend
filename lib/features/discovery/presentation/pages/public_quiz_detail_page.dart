import 'package:flutter/material.dart';

class PublicQuizDetailPage extends StatelessWidget {
  final dynamic quiz;

  const PublicQuizDetailPage({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final title = quiz['title'] ?? 'Sin título';
    final description = quiz['description'] ?? 'Sin descripción disponible.';
    final authorName = quiz['author'] != null
        ? quiz['author']['name']
        : 'Desconocido';
    final playCount = quiz['playCount'] ?? 0;
    final questionsCount =
        quiz['questionsCount'] ?? 0; // Si el backend lo manda
    final imageUrl = quiz['coverImageId'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Appbar con Imagen Grande (Efecto Parallax)
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(""), // Sin título al scrollear para no tapar
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

                  // Gradiente para que se vea bien el botón de atrás
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

          // 2. Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(quiz['category'] ?? 'General'),
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
                        _buildStat(
                          Icons.timer,
                          "---",
                          "Minutos",
                        ), // Dato calculado si lo tuviéramos
                        _buildStat(
                          Icons.star,
                          "4.5",
                          "Rating",
                        ), // Mock por ahora
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
