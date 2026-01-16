import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/library/domain/entities/kahoot_summary.dart';
import '../../../../injection_container.dart';
import '../bloc/kahoot_selection_bloc.dart';

class KahootSelectionPage extends StatelessWidget {
  const KahootSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KahootSelectionBloc>()..add(LoadMyKahootsEvent()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Seleccionar Actividad",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<KahootSelectionBloc, KahootSelectionState>(
          builder: (context, state) {
            if (state is KahootSelectionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is KahootSelectionLoaded) {
              if (state.kahoots.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.kahoots.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final kahoot = state.kahoots[index];
                  return _KahootSelectionCard(kahoot: kahoot);
                },
              );
            } else if (state is KahootSelectionError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No tienes Kahoots creados.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            "Crea uno en tu Biblioteca primero.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _KahootSelectionCard extends StatelessWidget {
  final KahootSummary kahoot;

  const _KahootSelectionCard({required this.kahoot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.quiz, color: Colors.deepPurple),
        ),
        title: Text(
          kahoot.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(kahoot.description ?? "Sin descripción"),
        trailing: const Icon(
          Icons.add_circle_outline,
          color: Colors.deepPurple,
        ),
        onTap: () => _showDatePicker(context, kahoot),
      ),
    );
  }

  void _showDatePicker(BuildContext context, KahootSummary kahoot) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: "FECHA LÍMITE DE ENTREGA",
      confirmText: "ASIGNAR",
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final endOfDay = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        23,
        59,
        59,
      );

      if (context.mounted) {
        Navigator.pop(context, {
          'quizId': kahoot.id,
          'quizTitle': kahoot.title,
          'availableUntil': endOfDay.toIso8601String(),
        });
      }
    }
  }
}
