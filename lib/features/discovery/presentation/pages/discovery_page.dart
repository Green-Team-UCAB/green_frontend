import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/discovery_bloc.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';
import '../../../shared/domain/entities/category.dart';

// CLASE PADRE: Inyección de Dependencias
class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DiscoveryBloc>()..add(DiscoveryStarted()),
      child: const DiscoveryView(),
    );
  }
}

// CLASE HIJA: UI
class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar'), elevation: 0),
      body: BlocConsumer<DiscoveryBloc, DiscoveryState>(
        listener: (context, state) {
          // Si se limpia la categoría y no hay resultados, limpiamos el input visualmente
          if (state.selectedCategoryName == null &&
              state.searchResults.isEmpty) {
            _searchController.clear();
          }
        },
        builder: (context, state) {
          // Loading inicial (solo si no hay datos previos)
          if (state.status == DiscoveryStatus.loading &&
              state.featuredKahoots.isEmpty &&
              state.searchResults.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DiscoveryStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          // Variables auxiliares para legibilidad
          final bool isFiltering = state.searchResults.isNotEmpty;
          final bool isCategorySelected = state.selectedCategoryName != null;
          final bool showHomeContent = !isFiltering && !isCategorySelected;

          return CustomScrollView(
            slivers: [
              // 1. Barra de Búsqueda (Siempre visible)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar kahoots...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: (isFiltering || isCategorySelected)
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                // Acción de limpiar todo
                                _searchController.clear();
                                context.read<DiscoveryBloc>().add(
                                  DiscoveryFilterCleared(),
                                );
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (val) => context.read<DiscoveryBloc>().add(
                      SearchQueryChanged(val),
                    ),
                  ),
                ),
              ),

              // 2. HEADER DE CATEGORÍA SELECCIONADA (Breadcrumb)
              if (isCategorySelected)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            context.read<DiscoveryBloc>().add(
                              DiscoveryFilterCleared(),
                            );
                          },
                        ),
                        Text(
                          'Categoría: ${state.selectedCategoryName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. CONTENIDO HOME (Solo si no hay filtros activos)
              if (showHomeContent) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        return _CategoryChip(category: state.categories[index]);
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Destacados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.featuredKahoots.length,
                      itemBuilder: (context, index) {
                        return _FeaturedCard(
                          kahoot: state.featuredKahoots[index],
                        );
                      },
                    ),
                  ),
                ),
              ],

              // 4. LISTA DE RESULTADOS (Si hay búsqueda o categoría seleccionada)
              if (isFiltering || isCategorySelected)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Si estamos filtrando pero la lista está vacía
                      if (state.searchResults.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              "No se encontraron resultados en esta categoría.",
                            ),
                          ),
                        );
                      }

                      final kahoot = state.searchResults[index];
                      return ListTile(
                        title: Text(kahoot.title),
                        subtitle: Text(kahoot.authorName),
                        leading: const CircleAvatar(child: Icon(Icons.quiz)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      );
                    },
                    // Hack: si está vacío mostramos 1 item (el mensaje de error arriba)
                    childCount: state.searchResults.isEmpty
                        ? 1
                        : state.searchResults.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _CategoryChip extends StatelessWidget {
  final Category category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(category.name),
        backgroundColor: Colors.deepPurple[50],
        labelStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          context.read<DiscoveryBloc>().add(
            CategorySelected(
              categoryId: category.id,
              categoryName: category.name,
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final KahootSummary kahoot;
  const _FeaturedCard({required this.kahoot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kahoot.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kahoot.authorName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        '${kahoot.playCount} plays',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
