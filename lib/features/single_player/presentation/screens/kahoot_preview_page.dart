// lib/features/single_player/presentation/screens/kahoot_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';
import 'package:green_frontend/core/storage/local_storage.dart';
import 'package:green_frontend/features/single_player/presentation/screens/game_page.dart';
import 'package:green_frontend/features/single_player/presentation/screens/summary_page.dart';

class KahootPreviewScreen extends StatefulWidget {
  final String kahootId;
  const KahootPreviewScreen({super.key, required this.kahootId});

  @override
  State<KahootPreviewScreen> createState() => _KahootPreviewScreenState();
}

class _KahootPreviewScreenState extends State<KahootPreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar preview después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().loadPreview(widget.kahootId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista Previa')),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          // Loading global
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (controller.lastFailure != null) {
            return _buildError(controller.lastFailure!.message);
          }

          final preview = controller.preview;
          if (preview == null) {
            return _buildError('No se encontró la previsualización.');
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail + favorite
                  _buildThumbnail(preview),

                  const SizedBox(height: 12),
                  Text(
                    preview.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if ((preview.description ?? '').isNotEmpty)
                    Text(
                      preview.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16),

                  // Progress card (if in progress or completed)
                  if (preview.isInProgress || preview.isCompleted)
                    _buildProgressCard(preview),

                  const SizedBox(height: 20),

                  // Action buttons
                  _buildActionButtons(controller, preview),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(preview) {
    final thumb = preview.thumbnailUrl;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: thumb != null && thumb.isNotEmpty
              ? Image.network(
                  thumb,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    );
                  },
                )
              : Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image)),
                ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: CircleAvatar(
            backgroundColor: Colors.white70,
            child: Icon(
              preview.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: preview.isFavorite ? Colors.red : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(preview) {
    final gs = preview.gameState;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado del intento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    preview.isInProgress ? 'En progreso' : 'No iniciado',
                  ),
                ),
                const SizedBox(width: 8),
                if (preview.isCompleted)
                  Chip(
                    label: Text('Completado'),
                    backgroundColor: Colors.green.shade100,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (gs != null) ...[
              Text('Intento: ${gs.attemptId}'),
              const SizedBox(height: 4),
              Text('Pregunta actual: ${gs.currentSlideIndex}'),
              const SizedBox(height: 4),
              Text('Puntuación: ${gs.score}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(GameController controller, preview) {
    final inProgress = preview.isInProgress == true;
    final completed = preview.isCompleted == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //  Jugar (nuevo intento)
        ElevatedButton(
          onPressed: controller.isLoading || controller.isSubmitting
              ? null
              : () => _startNewAttempt(context, controller),
          child: controller.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Jugar'),
        ),
        const SizedBox(height: 8),

        // Reanudar (si hay intento en progreso)
        if (inProgress)
          ElevatedButton(
            onPressed: controller.isLoading || controller.isSubmitting
                ? null
                : () => _resumeAttempt(context, controller, preview),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reanudar'),
          ),

        // Reiniciar (si hay intento en progreso)
        if (inProgress)
          TextButton(
            onPressed: controller.isLoading || controller.isSubmitting
                ? null
                : () => _confirmRestart(context, controller),
            child: const Text('Reiniciar intento'),
          ),

        // Ver resumen (si completado)
        if (completed)
          OutlinedButton(
            onPressed: controller.isLoading
                ? null
                : () => _viewSummary(context, controller, preview),
            child: const Text('Ver resumen'),
          ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              'Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ---------- Actions ----------

  Future<void> _startNewAttempt(
    BuildContext context,
    GameController controller,
  ) async {
    await controller.startNewAttempt(widget.kahootId, context);
    if (!mounted) return;

    // Si el controller guardó el attempt en su estado se navega a GamePage usando attemptId
    final attempt = controller.attempt;
    if (attempt != null) {
      try {
        await GameStorage.saveAttempt(attempt.attemptId, widget.kahootId);
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GamePage(attemptId: attempt.attemptId),
        ),
      );
    } else if (controller.lastFailure != null) {
      _showSnack(controller.lastFailure!.message);
    }
  }

  Future<void> _resumeAttempt(
    BuildContext context,
    GameController controller,
    dynamic preview,
  ) async {
    final attemptId = preview.gameState?.attemptId;
    if (attemptId != null && attemptId.isNotEmpty) {
      await controller.resumeAttempt(attemptId, context);
      if (!mounted) return;

      final attempt = controller.attempt;
      if (attempt != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GamePage(attemptId: attempt.attemptId),
          ),
        );
        return;
      }
      if (controller.lastFailure != null)
        _showSnack(controller.lastFailure!.message);
      return;
    }

    // Fallback: leer storage local
    final data = await GameStorage.getAttempt();
    final storedAttemptId = data['attemptId'];
    if (storedAttemptId != null) {
      await controller.resumeAttempt(storedAttemptId, context);
      if (!mounted) return;

      final attempt = controller.attempt;
      if (attempt != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GamePage(attemptId: attempt.attemptId),
          ),
        );
        return;
      }
      if (controller.lastFailure != null)
        _showSnack(controller.lastFailure!.message);
      return;
    }

    _showSnack('No se encontró un intento para reanudar.');
  }

  Future<void> _viewSummary(
    BuildContext context,
    GameController controller,
    dynamic preview,
  ) async {
    final attemptId =
        preview.gameState?.attemptId ??
        (await GameStorage.getAttempt())['attemptId'];
    if (attemptId == null) {
      _showSnack('No hay intento para ver resumen.');
      return;
    }
    await controller.loadSummary(attemptId, context);
    if (!mounted) return;

    if (controller.summary != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SummaryPage()),
      );
    } else if (controller.lastFailure != null) {
      _showSnack(controller.lastFailure!.message);
    }
  }

  Future<void> _confirmRestart(
    BuildContext context,
    GameController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reiniciar intento'),
        content: const Text(
          '¿Deseas reiniciar el intento y perder el progreso actual?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _startNewAttempt(context, controller);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
