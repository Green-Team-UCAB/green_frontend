import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/library_bloc.dart';
import '../../domain/entities/kahoot_summary.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Inyectamos el BLoC usando sl() configurado en injection_container
      create: (context) => sl<LibraryBloc>()..add(LoadLibraryDataEvent()),
      child: const LibraryView(),
    );
  }
}

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Kahoots, Favoritos, Actividad
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Biblioteca',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Mis Kahoots'), // H7.1
              Tab(text: 'Favoritos'), // H7.2
              Tab(text: 'Actividad'), // H7.5 + H7.6
            ],
          ),
        ),
        backgroundColor: Colors.grey[50],
        body: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LibraryError) {
              return _buildErrorView(context, state.message);
            } else if (state is LibraryLoaded) {
              return TabBarView(
                children: [
                  // Tab 1: Mis Creaciones
                  _LibraryListTab(
                    kahoots: state.myCreations,
                    emptyMessage: "Aún no has creado ningún Kahoot.",
                    icon: Icons.create,
                  ),

                  // Tab 2: Favoritos
                  _LibraryListTab(
                    kahoots: state.favorites,
                    emptyMessage: "No tienes favoritos guardados.",
                    icon: Icons.favorite_border,
                  ),

                  // Tab 3: Actividad (En Progreso + Completados)
                  _ActivityTab(
                    inProgress: state.inProgress,
                    completed: state.completed,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<LibraryBloc>().add(LoadLibraryDataEvent()),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB GENÉRICA CON PULL-TO-REFRESH ---
class _LibraryListTab extends StatelessWidget {
  final List<KahootSummary> kahoots;
  final String emptyMessage;
  final IconData icon;

  const _LibraryListTab({
    required this.kahoots,
    required this.emptyMessage,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.deepPurple,
      onRefresh: () async {
        context.read<LibraryBloc>().add(LoadLibraryDataEvent());
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Pequeña espera UX
      },
      child: kahoots.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kahoots.length,
              itemBuilder: (context, index) {
                return _LibraryKahootCard(kahoot: kahoots[index]);
              },
            ),
    );
  }
}

// --- TAB DE ACTIVIDAD (COMBINADA) ---
class _ActivityTab extends StatelessWidget {
  final List<KahootSummary> inProgress;
  final List<KahootSummary> completed;

  const _ActivityTab({required this.inProgress, required this.completed});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.deepPurple,
      onRefresh: () async {
        context.read<LibraryBloc>().add(LoadLibraryDataEvent());
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (inProgress.isEmpty && completed.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      "No hay actividad reciente.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

          if (inProgress.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
              child: Text(
                "EN CURSO",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...inProgress.map(
              (k) => _LibraryKahootCard(kahoot: k, isProgress: true),
            ),
          ],

          if (completed.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
              child: Text(
                "COMPLETADOS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...completed.map((k) => _LibraryKahootCard(kahoot: k)),
          ],
        ],
      ),
    );
  }
}

// --- TARJETA REUTILIZABLE ---
class _LibraryKahootCard extends StatelessWidget {
  final KahootSummary kahoot;
  final bool isProgress;

  const _LibraryKahootCard({required this.kahoot, this.isProgress = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navegación al detalle
          // Navigator.push(context, MaterialPageRoute(builder: (_) => PublicQuizDetailPage(quiz: kahoot)));
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Imagen Miniatura
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                  image:
                      (kahoot.coverImageId != null &&
                          kahoot.coverImageId!.startsWith('http'))
                      ? DecorationImage(
                          image: NetworkImage(kahoot.coverImageId!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: kahoot.coverImageId == null
                    ? const Center(child: Icon(Icons.image, color: Colors.grey))
                    : null,
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de progreso
                    if (isProgress)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "En progreso • ${kahoot.gameType ?? 'Juego'}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),

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
                    Text(
                      "${kahoot.playCount} jugadas • ${kahoot.status ?? 'Draft'}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (kahoot.authorName != null)
                      Text(
                        "Por ${kahoot.authorName}",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // Botón Corazón (Acción H7.3 / H7.4)
              IconButton(
                icon: Icon(
                  kahoot.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: kahoot.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  context.read<LibraryBloc>().add(
                    ToggleFavoriteInLibraryEvent(
                      kahootId: kahoot.id,
                      isCurrentlyFavorite: kahoot.isFavorite,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
