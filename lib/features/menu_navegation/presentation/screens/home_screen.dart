import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';
import 'package:green_frontend/features/single_player/domain/entities/kahoot.dart';
import 'package:green_frontend/core/storage/local_storage.dart';

/// Colors para las tarjetas
class _CardColors {
  static const List<Color> cardColors = [
    Color(0xFF7C4DFF), // Morado
    Color(0xFF2196F3), // Azul
    Color(0xFF4CAF50), // Verde
    Color(0xFFFF9800), // Naranja
    Color(0xFFE91E63), // Rosa
    Color(0xFF009688), // Turquesa
    Color(0xFF9C27B0), // Púrpura
    Color(0xFF3F51B5), // Índigo
    Color(0xFF00BCD4), // Cian
    Color(0xFF8BC34A), // Verde claro
  ];

  static const Color textOnDark = Colors.white;
  static const Color textOnLight = Color(0xFF1A1A1A);
}

/// IDs de los kahoots reales de tu API
class KahootIds {
  static const List<String> allKahootIds = [
    '1c7ebd51-ab08-4f29-b0b3-14ad7429f83f',
    '687215ca-79ed-44e5-a8d2-b06a08597c9c',
    'f7e2f27b-ade3-4763-b7ab-da94e9ab2f4d',
    'ae97ba14-f1b5-4f93-9054-ab0341c33212',
    '9cb9aa6f-3f6a-42a1-952c-3451a786e6e0',
  ];
}

class KahootLibraryScreen extends StatefulWidget {
  const KahootLibraryScreen({super.key});

  @override
  State<KahootLibraryScreen> createState() => _KahootLibraryScreenState();
}

class _KahootLibraryScreenState extends State<KahootLibraryScreen> {
  // Mapa para guardar los previews cargados por ID
  final Map<String, Kahoot?> _kahootPreviews = {};
  final Set<String> _loadingKahoots = {};

  // Variable para controlar si debemos continuar con las peticiones
  bool _shouldContinue = true;

  @override
  void initState() {
    super.initState();
    // Cargar todos los previews después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllKahootPreviews();
    });
  }

  @override
  void dispose() {
    _shouldContinue = false; // Detener todas las peticiones futuras
    super.dispose();
  }

  Future<void> _loadAllKahootPreviews() async {
    // Verificar si debemos continuar antes de empezar
    if (!_shouldContinue || !mounted) return;

    for (final kahootId in KahootIds.allKahootIds) {
      // Verificar después de cada kahoot si debemos continuar
      if (!_shouldContinue || !mounted) break;
      await _loadKahootPreview(kahootId);
    }
  }

  Future<void> _loadKahootPreview(String kahootId) async {
    // Verificar múltiples condiciones antes de continuar
    if (_loadingKahoots.contains(kahootId) || !mounted || !_shouldContinue)
      return;

    _loadingKahoots.add(kahootId);
    if (mounted) setState(() {});

    try {
      // OBTENER EL PROVIDER USANDO UN BUILD CONTEXT VÁLIDO
      final controller = Provider.of<GameController>(context, listen: false);

      final result = await controller.getKahootPreviewAsync(kahootId);

      // Verificar si el widget sigue montado y debemos continuar
      if (!mounted || !_shouldContinue) {
        _loadingKahoots.remove(kahootId);
        return;
      }

      result.match(
        (failure) {
          if (mounted && _shouldContinue) {
            setState(() {
              _kahootPreviews[kahootId] = null;
            });
          }
        },
        (kahoot) {
          if (mounted && _shouldContinue) {
            setState(() {
              _kahootPreviews[kahootId] = kahoot;
            });
          }
        },
      );
    } catch (e) {
      // Manejar cualquier excepción
      if (mounted && _shouldContinue) {
        setState(() {
          _kahootPreviews[kahootId] = null;
        });
      }
    } finally {
      _loadingKahoots.remove(kahootId);
      if (mounted && _shouldContinue) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis kahoots',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildMainContent(context),
    );
  }

  /// Contenido principal
  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Título simple
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${KahootIds.allKahootIds.length} Kahoots disponibles',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ),

        const SizedBox(height: 8),
        const Divider(height: 1, color: Color(0xFFE6E6E6)),

        // Lista de Kahoots desde la API
        Expanded(
          child: Consumer<GameController>(
            builder: (context, controller, child) {
              // Si está cargando por primera vez
              if (_kahootPreviews.isEmpty && _loadingKahoots.isNotEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columnas
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8, // Relación ancho/alto
                ),
                itemCount: KahootIds.allKahootIds.length,
                itemBuilder: (context, index) {
                  final kahootId = KahootIds.allKahootIds[index];
                  final kahoot = _kahootPreviews[kahootId];
                  final isLoading = _loadingKahoots.contains(kahootId);

                  return _KahootCard(
                    kahootId: kahootId,
                    kahoot: kahoot,
                    isLoading: isLoading,
                    controller: controller,
                    cardColor: _CardColors
                        .cardColors[index % _CardColors.cardColors.length],
                    onRefresh: () => _loadKahootPreview(kahootId),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Widget de tarjeta individual para cada Kahoot
class _KahootCard extends StatelessWidget {
  final String kahootId;
  final Kahoot? kahoot;
  final bool isLoading;
  final GameController controller;
  final Color cardColor;
  final VoidCallback onRefresh;

  const _KahootCard({
    required this.kahootId,
    required this.kahoot,
    required this.isLoading,
    required this.controller,
    required this.cardColor,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Datos del kahoot (si ya se cargó) o valores por defecto
    final title = kahoot?.title ?? 'Cargando...';
    final description = kahoot?.description ?? '';
    final isInProgress = kahoot?.isInProgress ?? false;
    final isCompleted = kahoot?.isCompleted ?? false;

    // Determinar si el color es claro u oscuro para ajustar el texto
    final brightness = ThemeData.estimateBrightnessForColor(cardColor);
    final textColor = brightness == Brightness.dark
        ? _CardColors.textOnDark
        : _CardColors.textOnLight;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              _showKahootPreview(context, kahootId, controller);
            },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de quiz
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(Icons.quiz, color: textColor, size: 28),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Descripción (si existe)
                  if (description.isNotEmpty)
                    Expanded(
                      child: Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Estado
                  if (!isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isInProgress
                            ? 'En progreso'
                            : isCompleted
                            ? 'Completado'
                            : 'Nuevo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Botón de acción en la esquina inferior derecha
            if (!isLoading)
              Positioned(
                bottom: 12,
                right: 12,
                child: _buildActionButton(
                  context,
                  isInProgress,
                  isCompleted,
                  textColor,
                ),
              ),

            // Indicador de carga
            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isInProgress,
    bool isCompleted,
    Color textColor,
  ) {
    if (isInProgress) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.orange, size: 20),
          onPressed: () => _resumeGame(context, controller, kahootId, null),
          padding: EdgeInsets.zero,
        ),
      );
    } else if (isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.replay, color: Colors.green, size: 20),
          onPressed: () => _startNewGame(context, controller, kahootId),
          padding: EdgeInsets.zero,
        ),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.play_arrow, color: cardColor, size: 20),
          onPressed: () => _startNewGame(context, controller, kahootId),
          padding: EdgeInsets.zero,
        ),
      );
    }
  }

  // Métodos de acción
  Future<void> _startNewGame(
    BuildContext context,
    GameController controller,
    String kahootId,
  ) async {
    await controller.startNewAttempt(kahootId, context);
  }

  Future<void> _resumeGame(
    BuildContext context,
    GameController controller,
    String kahootId,
    dynamic gameState,
  ) async {
    final attemptId = gameState?.attemptId;
    if (attemptId != null && attemptId.isNotEmpty) {
      await controller.resumeAttempt(attemptId, context);
    } else {
      final data = await GameStorage.getAttempt();
      final storedAttemptId = data['attemptId'];
      if (!context.mounted) return;
      if (storedAttemptId != null) {
        await controller.resumeAttempt(storedAttemptId, context);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontró un intento para reanudar'),
            ),
          );
        }
      }
    }
  }

  void _showKahootPreview(
    BuildContext context,
    String kahootId,
    GameController controller,
  ) {
    // Navegar a pantalla de preview detallada
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _KahootPreviewModal(kahootId: kahootId, controller: controller);
      },
    );
  }
}

/// Modal para mostrar preview detallado
class _KahootPreviewModal extends StatelessWidget {
  final String kahootId;
  final GameController controller;

  const _KahootPreviewModal({required this.kahootId, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, child) {
        final kahoot = controller.preview;
        final isLoading = controller.isLoading;
        final error = controller.lastFailure;

        if (isLoading) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (error != null) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${error.message}'),
                ],
              ),
            ),
          );
        }

        if (kahoot == null) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text('No se pudo cargar la información')),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                kahoot.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              if (kahoot.description != null && kahoot.description!.isNotEmpty)
                Text(
                  kahoot.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B6B6B),
                  ),
                ),

              const SizedBox(height: 16),

              // Estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, color: const Color(0xFF7C4DFF), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      kahoot.isInProgress
                          ? 'En progreso'
                          : kahoot.isCompleted
                          ? 'Completado'
                          : 'No iniciado',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón principal de acción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.startNewAttempt(kahootId, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Comenzar juego',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
