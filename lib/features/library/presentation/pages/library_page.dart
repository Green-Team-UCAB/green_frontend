import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/library_bloc.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';
// Importamos el módulo de Reportes que ya hicimos
import '../../../reports/presentation/pages/reports_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
      length: 3, // 3 Pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kahoots'),
              Tab(text: 'Favoritos'),
              Tab(text: 'Informes'), // Aquí va la Epica 10
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Mis Kahoots
            _MyKahootsTab(),

            // Tab 2: Favoritos
            _FavoritesTab(),

            // Tab 3: Informes (Reutilizamos la página entera)
            // Nota: ReportsPage tiene su propio Scaffold y AppBar.
            // En una app real, refactorizaríamos ReportsPage para ser solo una View sin Scaffold,
            // pero para este MVP funciona bien anidado.
            const ReportsPage(),
          ],
        ),
      ),
    );
  }
}

class _MyKahootsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is LibraryLoaded)
          return _KahootList(kahoots: state.myKahoots);
        if (state is LibraryError) return Center(child: Text(state.message));
        return const SizedBox.shrink();
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is LibraryLoaded)
          return _KahootList(kahoots: state.favorites);
        if (state is LibraryError) return Center(child: Text(state.message));
        return const SizedBox.shrink();
      },
    );
  }
}

class _KahootList extends StatelessWidget {
  final List<KahootSummary> kahoots;
  const _KahootList({required this.kahoots});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kahoots.length,
      itemBuilder: (context, index) {
        final k = kahoots[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.quiz, size: 40, color: Colors.deepPurple),
            title: Text(
              k.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${k.status} • ${k.playCount} jugadas"),
            trailing: const Icon(Icons.more_vert),
          ),
        );
      },
    );
  }
}
