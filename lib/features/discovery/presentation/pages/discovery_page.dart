import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/discovery_bloc.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';

// ==========================================
// 1. CLASE PADRE: SOLO INYECTA
// ==========================================
class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Crea el BLoC y se lo pasa al hijo (DiscoveryView)
    return BlocProvider(
      create: (context) =>
          sl<DiscoveryBloc>()..add(const SearchQueryChanged('')),
      child: const DiscoveryView(),
    );
  }
}

// ==========================================
// 2. CLASE HIJA: DIBUJA LA UI Y USA EL BLOC
// ==========================================
class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí el 'context' YA ve al BlocProvider del padre
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Kahoots')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por título o autor',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // ESTO SOLO FUNCIONA SI ESTAMOS EN UN HIJO DEL BLOCPROVIDER
                context.read<DiscoveryBloc>().add(SearchQueryChanged(value));
              },
            ),
          ),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        if (state is DiscoveryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DiscoveryLoaded) {
          if (state.kahoots.isEmpty) {
            return const Center(child: Text('No se encontraron resultados.'));
          }
          return ListView.builder(
            itemCount: state.kahoots.length,
            itemBuilder: (context, index) {
              final kahoot = state.kahoots[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.quiz)),
                title: Text(kahoot.title),
                subtitle: Text('Por: ${kahoot.authorName}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 16),
                    Text('${kahoot.playCount}'),
                  ],
                ),
              );
            },
          );
        } else if (state is DiscoveryError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
