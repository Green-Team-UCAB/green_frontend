import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';
import 'package:green_frontend/features/single_player/domain/entities/kahoot.dart';
import 'package:green_frontend/core/storage/local_storage.dart';


/// Colors centralizados para mantener consistencia visual
class _AppColors {
  static const primary = Color(0xFF7C4DFF); // Morado de acento
  static const background = Colors.white;
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const border = Color(0xFFE6E6E6);
  static const chip = Color(0xFFF5F5F5);
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
  int _segmentIndex = 0; // 0: Quizzo, 1: Collections
  String _sortLabel = 'Newest';
  
  // Mapa para guardar los previews cargados por ID
  final Map<String, Kahoot?> _kahootPreviews = {};
  final Set<String> _loadingKahoots = {};

  @override
  void initState() {
    super.initState();
    // Cargar todos los previews después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllKahootPreviews();
    });
  }

  Future<void> _loadAllKahootPreviews() async {
    for (final kahootId in KahootIds.allKahootIds) {
      await _loadKahootPreview(kahootId);
    }
  }

  Future<void> _loadKahootPreview(String kahootId) async {
    if (_loadingKahoots.contains(kahootId)) return;
    
    _loadingKahoots.add(kahootId);
    if (mounted) setState(() {});
    
    final controller = context.read<GameController>();
    
    final result = await controller.getKahootPreviewAsync(kahootId);
    
    result.match(
      (failure) {
        // Error - dejar null en el mapa
        if (mounted) {
          setState(() {
            _kahootPreviews[kahootId] = null;
          });
        }
      },
      (kahoot) {
        // Éxito - guardar en el mapa
        if (mounted) {
          setState(() {
            _kahootPreviews[kahootId] = kahoot;
          });
        }
      },
    );
    
    _loadingKahoots.remove(kahootId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // My Quizzo, Favorites, Collaboration
      child: Scaffold(
        backgroundColor: _AppColors.background,
        appBar: AppBar(
          backgroundColor: _AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          title: const Text('Mis kahoots', style: TextStyle(color: _AppColors.textPrimary, fontWeight: FontWeight.w700)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Column(
              children: [
                // Tab bar: My Quizzo | Favorites | Collaboration
                TabBar(
                  labelColor: _AppColors.primary,
                  unselectedLabelColor: _AppColors.textSecondary,
                  indicatorColor: _AppColors.primary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'My Quizzo'),
                    Tab(text: 'Favorites'),
                    Tab(text: 'Collaboration'),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(context, 'My Quizzo'),
            _buildTabContent(context, 'Favorites'),
            _buildTabContent(context, 'Collaboration'),
          ],
        ),
      ),
    );
  }

  /// Contenido principal por pestaña
  Widget _buildTabContent(BuildContext context, String tabName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final horizontalPadding = isCompact ? 12.0 : 16.0;

        return Column(
          children: [
            const SizedBox(height: 12),
            // Segment control: Quizzo | Collections
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: _SegmentedControl(
                segments: const ['Quizzo', 'Collections'],
                selectedIndex: _segmentIndex,
                onChanged: (i) => setState(() => _segmentIndex = i),
              ),
            ),
            const SizedBox(height: 12),
            // Header row: "X Quizzo" | Sort "Newest"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${KahootIds.allKahootIds.length} ',
                            style: const TextStyle(
                              color: _AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: _segmentIndex == 0 ? 'Quizzo' : 'Collections',
                            style: const TextStyle(
                              color: _AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Cambiar orden
                      setState(() {
                        _sortLabel = _sortLabel == 'Newest' ? 'Oldest' : 'Newest';
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sortLabel,
                          style: const TextStyle(
                            color: _AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _sortLabel == 'Newest' ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 18,
                          color: _AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: _AppColors.border),
            // Lista de Kahoots desde la API
            Expanded(
              child: Consumer<GameController>(
                builder: (context, controller, child) {
                  // Si está cargando por primera vez
                  if (_kahootPreviews.isEmpty && _loadingKahoots.isNotEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding, 12, horizontalPadding, 12
                    ),
                    itemCount: KahootIds.allKahootIds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final kahootId = KahootIds.allKahootIds[index];
                      final kahoot = _kahootPreviews[kahootId];
                      final isLoading = _loadingKahoots.contains(kahootId);
                      
                      return _KahootCard(
                        kahootId: kahootId,
                        kahoot: kahoot,
                        isLoading: isLoading,
                        controller: controller,
                        onRefresh: () => _loadKahootPreview(kahootId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget de tarjeta individual para cada Kahoot
class _KahootCard extends StatelessWidget {
  final String kahootId;
  final Kahoot? kahoot;
  final bool isLoading;
  final GameController controller;
  final VoidCallback onRefresh;

  const _KahootCard({
    required this.kahootId,
    required this.kahoot,
    required this.isLoading,
    required this.controller,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Datos del kahoot (si ya se cargó) o valores por defecto
    final title = kahoot?.title ?? 'Cargando...';
    final description = kahoot?.description ?? '';
    final thumbnailUrl = kahoot?.thumbnailUrl;
    final isFavorite = kahoot?.isFavorite ?? false;
    final isInProgress = kahoot?.isInProgress ?? false;
    final isCompleted = kahoot?.isCompleted ?? false;
    final gameState = kahoot?.gameState;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : () {
          _showKahootPreview(context, kahootId, controller);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              _buildThumbnail(
                thumbnailUrl, 
                isLoading, 
                isInProgress, 
                isCompleted
              ),
              
              const SizedBox(width: 12),
              
              // Contenido de texto y acciones
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Descripción (si existe)
                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    
                    const SizedBox(height: 10),
                    
                    // Estado y acciones
                    _buildStatusAndActions(
                      context,
                      isInProgress,
                      isCompleted,
                      gameState,
                      isLoading,
                    ),
                  ],
                ),
              ),
              
              // Botón de favorito
              if (!isLoading)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : _AppColors.textSecondary,
                  ),
                  onPressed: () {
                    // TODO: Implementar toggle favorite
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    String? thumbnailUrl, 
    bool isLoading,
    bool isInProgress,
    bool isCompleted
  ) {
    if (isLoading) {
      return Container(
        width: 96,
        height: 72,
        decoration: BoxDecoration(
          color: _AppColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    Color statusColor = Colors.grey;
    if (isInProgress) statusColor = Colors.orange;
    if (isCompleted) statusColor = Colors.green;

    return Stack(
      children: [
        // Imagen del thumbnail
        Container(
          width: 96,
          height: 72,
          decoration: BoxDecoration(
            color: thumbnailUrl != null ? null : _AppColors.chip,
            borderRadius: BorderRadius.circular(12),
            image: thumbnailUrl != null
                ? DecorationImage(
                    image: NetworkImage(thumbnailUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: thumbnailUrl == null
              ? const Icon(Icons.quiz, color: _AppColors.primary, size: 28)
              : null,
        ),
        
        // Indicador de estado (solo si hay estado)
        if (isInProgress || isCompleted)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusAndActions(
    BuildContext context,
    bool isInProgress,
    bool isCompleted,
    dynamic gameState,
    bool isLoading,
  ) {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado
        Row(
          children: [
            if (isInProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En progreso',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ),
            
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Completado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            
            if (!isInProgress && !isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No iniciado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Botones de acción rápida
        if (isInProgress || isCompleted)
          Wrap(
            spacing: 8,
            children: [
              if (isInProgress)
                ElevatedButton(
                  onPressed: () => _resumeGame(context, controller, kahootId, gameState),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Reanudar',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              
              if (isInProgress)
                OutlinedButton(
                  onPressed: () => _confirmRestart(context, controller, kahootId),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    side: const BorderSide(color: Colors.orange),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Reiniciar',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              
              if (isCompleted)
                OutlinedButton(
                  onPressed: () => _viewSummary(context, controller, kahootId, gameState),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    side: const BorderSide(color: Colors.green),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Ver resumen',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
            ],
          ),
        
        // Botón principal de juego
        if (!isInProgress && !isCompleted)
          ElevatedButton(
            onPressed: () => _startNewGame(context, controller, kahootId),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
            child: const Text(
              'Jugar ahora',
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  // Métodos de acción
  Future<void> _startNewGame(BuildContext context, GameController controller, String kahootId) async {
    await controller.startNewAttempt(kahootId, context);
  }

  Future<void> _resumeGame(BuildContext context, GameController controller, String kahootId, dynamic gameState) async {
    final attemptId = gameState?.attemptId;
    if (attemptId != null && attemptId.isNotEmpty) {
      await controller.resumeAttempt(attemptId, context);
    } else {
      final data = await GameStorage.getAttempt();
      final storedAttemptId = data['attemptId'];
      if (storedAttemptId != null) {
        await controller.resumeAttempt(storedAttemptId, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró un intento para reanudar')),
        );
      }
    }
  }

  Future<void> _viewSummary(BuildContext context, GameController controller, String kahootId, dynamic gameState) async {
    final attemptId = gameState?.attemptId ?? (await GameStorage.getAttempt())['attemptId'];
    if (attemptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay intento para ver resumen')),
      );
      return;
    }
    await controller.loadSummary(attemptId, context);
  }

  Future<void> _confirmRestart(BuildContext context, GameController controller, String kahootId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reiniciar intento'),
        content: const Text('¿Deseas reiniciar el intento y perder el progreso actual?'),
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
      await _startNewGame(context, controller, kahootId);
    }
  }

  void _showKahootPreview(BuildContext context, String kahootId, GameController controller) {
    // Navegar a pantalla de preview detallada
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _KahootPreviewModal(
          kahootId: kahootId,
          controller: controller,
        );
      },
    );
  }
}

/// Modal para mostrar preview detallado
class _KahootPreviewModal extends StatelessWidget {
  final String kahootId;
  final GameController controller;

  const _KahootPreviewModal({
    required this.kahootId,
    required this.controller,
  });

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
              // Thumbnail grande
              if (kahoot.thumbnailUrl != null && kahoot.thumbnailUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    kahoot.thumbnailUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Título y descripción
              Text(
                kahoot.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              const SizedBox(height: 8),
              
              if (kahoot.description != null && kahoot.description!.isNotEmpty)
                Text(
                  kahoot.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              
              const SizedBox(height: 16),
              
              // Estadísticas básicas
              Row(
                children: [
                  _StatItem(
                    icon: Icons.gamepad,
                    label: 'Estado',
                    value: kahoot.isInProgress ? 'En progreso' : 
                           kahoot.isCompleted ? 'Completado' : 'No iniciado',
                  ),
                  const SizedBox(width: 20),
                  _StatItem(
                    icon: Icons.favorite,
                    label: 'Favorito',
                    value: kahoot.isFavorite ? 'Sí' : 'No',
                  ),
                ],
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
                  child: const Text('Comenzar juego'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Segmented control estilo "pills"
class _SegmentedControl extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: _AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(segments.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onChanged(i),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  segments[i],
                  style: TextStyle(
                    color: selected ? Colors.white : _AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}