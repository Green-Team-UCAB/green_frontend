import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/discovery_bloc.dart';
import '../bloc/discovery_event.dart';
import '../bloc/discovery_state.dart';
import 'public_quiz_detail_page.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DiscoveryBloc>()..add(LoadDiscoveryDataEvent()),
      child: const _DiscoveryView(),
    );
  }
}

class _DiscoveryView extends StatefulWidget {
  const _DiscoveryView();

  @override
  State<_DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<_DiscoveryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Descubrir",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {}, // Futura implementación de notificaciones
          ),
        ],
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state is DiscoveryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DiscoveryError) {
            return _buildErrorState(context, state.message);
          } else if (state is DiscoveryLoaded) {
            return RefreshIndicator(
              color: Colors.deepPurple,
              onRefresh: () async {
                context.read<DiscoveryBloc>().add(LoadDiscoveryDataEvent());
                // Pequeña espera visual para que se sienta la recarga
                await Future.delayed(const Duration(seconds: 1));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Barra de Búsqueda
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSearchBar(context, state),
                    ),
                  ),

                  // 2. Lista de Categorías CON TÍTULO
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            "Categorías",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildCategoriesList(context, state),
                        const SizedBox(height: 16), // Espacio extra abajo
                      ],
                    ),
                  ),

                  // 3. Contenido Principal (Destacados o Resultados)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _determineContent(context, state),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- WIDGETS DE UI ---

  Widget _buildSearchBar(BuildContext context, DiscoveryLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<DiscoveryBloc>().add(SearchQuizzesEvent(value));
        },
        decoration: InputDecoration(
          hintText: "Buscar por título, tema o autor...",
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    context.read<DiscoveryBloc>().add(ClearSearchEvent());
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, DiscoveryLoaded state) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (c, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final isSelected = state.activeCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            selectedColor: Colors.deepPurple,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
              ),
            ),
            onSelected: (_) {
              context.read<DiscoveryBloc>().add(ToggleCategoryEvent(category));
            },
          );
        },
      ),
    );
  }

  // Lógica para decidir qué mostrar: ¿Resultados de búsqueda o Destacados?
  Widget _determineContent(BuildContext context, DiscoveryLoaded state) {
    // Si hay texto escrito, una categoría seleccionada, o está cargando búsqueda: MODO BÚSQUEDA
    if (state.searchQuery.isNotEmpty ||
        state.activeCategory.isNotEmpty ||
        state.isSearching) {
      if (state.isSearching) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (state.searchResults.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No encontramos resultados para tu búsqueda.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      // LISTA DE RESULTADOS
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final quiz = state.searchResults[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuizResultCard(quiz: quiz),
          );
        }, childCount: state.searchResults.length),
      );
    }

    // MODO DEFAULT (ESCAPARATE)
    return SliverList(
      delegate: SliverChildListDelegate([
        const Text(
          "Destacados para ti",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (state.featuredQuizzes.isEmpty)
          const Text("No hay destacados por el momento.")
        else
          SizedBox(
            height: 240, // Altura del carrusel horizontal
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.featuredQuizzes.length,
              separatorBuilder: (c, i) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _FeaturedQuizCard(quiz: state.featuredQuizzes[index]);
              },
            ),
          ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<DiscoveryBloc>().add(LoadDiscoveryDataEvent()),
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}

// --- TARJETAS ---

class _FeaturedQuizCard extends StatelessWidget {
  final dynamic quiz;
  const _FeaturedQuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PublicQuizDetailPage(quiz: quiz)),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de Portada
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.grey.shade200,
                  image:
                      quiz['coverImageId'] != null &&
                          (quiz['coverImageId'] as String).startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(quiz['coverImageId']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    quiz['coverImageId'] == null ||
                        !(quiz['coverImageId'] as String).startsWith('http')
                    ? const Center(child: Icon(Icons.image, color: Colors.grey))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz['category'] ?? 'General',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz['title'] ?? 'Sin título',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          quiz['author'] != null
                              ? quiz['author']['name'] ?? 'Anónimo'
                              : 'Anónimo',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizResultCard extends StatelessWidget {
  final dynamic quiz;
  const _QuizResultCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PublicQuizDetailPage(quiz: quiz)),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Miniatura Cuadrada
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  image:
                      quiz['coverImageId'] != null &&
                          (quiz['coverImageId'] as String).startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(quiz['coverImageId']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    quiz['coverImageId'] == null ||
                        !(quiz['coverImageId'] as String).startsWith('http')
                    ? const Icon(Icons.quiz, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['title'] ?? 'Sin título',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz['description'] ?? 'Sin descripción',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            quiz['category'] ?? 'General',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${quiz['questionsCount'] ?? 0} preguntas",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
