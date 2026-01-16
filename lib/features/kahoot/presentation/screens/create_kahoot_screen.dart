import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'package:green_frontend/features/kahoot/domain/entities/theme_image.dart';
import 'package:green_frontend/features/kahoot/presentation/screens/normal_question_screen.dart';
import 'package:green_frontend/features/kahoot/presentation/screens/question_type_selection_screen.dart';
import 'package:green_frontend/features/kahoot/presentation/screens/true_false_question_screen.dart';
import 'package:green_frontend/features/kahoot/presentation/widgets/question_tile.dart';
import 'package:provider/provider.dart';
import 'theme_selection_screen.dart';
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/application/providers/theme_provider.dart';
import 'package:green_frontend/features/media/application/providers/media_provider.dart';
import 'package:green_frontend/features/discovery/application/providers/category_provider.dart';

class CreateKahootScreen extends StatefulWidget {
  CreateKahootScreen({Key? key}) : super(key: key);

  @override
  _CreateKahootScreenState createState() => _CreateKahootScreenState();
}

class _CreateKahootScreenState extends State<CreateKahootScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedVisibility = 'private';
  String? _selectedCategory;
  String? _selectedThemeName = 'Seleccionar tema';
  String? _selectedThemeId = '';
  String? _selectedCoverImageId;
  String? _selectedCoverLocalPath;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final kahootProvider =
          Provider.of<KahootProvider>(context, listen: false);

      if (themeProvider.themes.isEmpty) {
        themeProvider.loadThemes();
      }

      if (categoryProvider.categories.isEmpty) {
        categoryProvider.loadCategories();
      }

      // Populate fields if Kahoot data exists (e.g. from AI)
      final currentKahoot = kahootProvider.currentKahoot;

      if (currentKahoot.title.isNotEmpty) {
        _titleController.text = currentKahoot.title;
      }

      if (currentKahoot.description?.isNotEmpty ?? false) {
        _descriptionController.text = currentKahoot.description!;
      }
    });
  }

  Future<void> _pickCoverImage() async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    try {
      final media = await mediaProvider.pickImageFromGallery();
      if (!mounted) return;
      if (media != null) {
        setState(() {
          _selectedCoverImageId = media.id;
          _selectedCoverLocalPath = media.localPath;
        });

        final kahootProvider =
            Provider.of<KahootProvider>(context, listen: false);
        kahootProvider.setCoverImageId(media.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen de portada añadida correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _removeCoverImage() {
    setState(() {
      _selectedCoverImageId = null;
      _selectedCoverLocalPath = null;
    });

    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    kahootProvider.setCoverImageId(null);
  }

  @override
  Widget build(BuildContext context) {
    final kahootProvider = Provider.of<KahootProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final mediaProvider = Provider.of<MediaProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Kahoot'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El título es requerido')),
                );
                return;
              }

              if (kahootProvider.currentKahoot.themeId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Debe seleccionar un tema para el Kahoot'),
                  ),
                );
                return;
              }

              if (kahootProvider.currentKahoot.questions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Debe agregar al menos una pregunta')),
                );
                return;
              }

              await kahootProvider.saveKahoot();
              if (!mounted) return;
              if (kahootProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kahoot guardado exitosamente')),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(kahootProvider.error!)));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada con multimedia
            _buildCoverImageSection(mediaProvider),

            SizedBox(height: 24),

            // Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Escribe título',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => kahootProvider.setTitle(value),
            ),
            SizedBox(height: 16),

            // Descripción
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Escribe una descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => kahootProvider.setDescription(value),
            ),
            SizedBox(height: 16),

            // Tema
            StatefulBuilder(
              builder: (context, setState) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Tema'),
                  subtitle: Text(_selectedThemeName!),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    if (themeProvider.themes.isEmpty) {
                      await themeProvider.loadThemes();
                      if (!mounted) return;
                    }
                    final selectedTheme = await Navigator.push<ThemeImage?>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThemeSelectionScreen(),
                      ),
                    );
                    if (selectedTheme != null) {
                      setState(() {
                        _selectedThemeName = selectedTheme.name;
                        _selectedThemeId = selectedTheme.id;
                      });

                      kahootProvider.setThemeId(selectedTheme.id);
                    }
                  },
                );
              },
            ),
            Divider(),

            // Visibilidad
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Visible para'),
              trailing: DropdownButton<String>(
                value: _selectedVisibility,
                onChanged: (value) {
                  setState(() {
                    _selectedVisibility = value;
                  });
                  kahootProvider.setVisibility(value!);
                },
                items: [
                  DropdownMenuItem(value: 'public', child: Text('Público')),
                  DropdownMenuItem(value: 'private', child: Text('Privado')),
                ],
              ),
            ),
            Divider(),

            // Categoría - Ahora dinámica desde el backend
            _buildCategorySection(categoryProvider, kahootProvider),
            Divider(),

            // Preguntas
            Text(
              'Preguntas (${kahootProvider.currentKahoot.questions.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            if (kahootProvider.currentKahoot.questions.isNotEmpty)
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: kahootProvider.currentKahoot.questions
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return QuestionTile(
                    key: ValueKey(question.id ?? index),
                    question: question,
                    index: index,
                    onTap: () {
                      if (question.type == QuestionType.quiz) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NormalQuestionScreen(
                              questionIndex: index,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrueFalseQuestionScreen(
                              questionIndex: index,
                            ),
                          ),
                        );
                      }
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Eliminar pregunta'),
                          content: Text(
                              '¿Estás seguro de que quieres eliminar esta pregunta?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                kahootProvider.removeQuestion(index);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Pregunta eliminada correctamente')),
                                );
                              },
                              child: Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    // ✅ NUEVO: Funcionalidad para duplicar pregunta (H2.14)
                    onDuplicate: () {
                      kahootProvider.duplicateQuestion(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Pregunta duplicada correctamente')),
                      );
                    },
                    // ✅ NUEVO: Funcionalidad para cambiar puntuación (H2.12)
                    onChangePoints: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final pointsController = TextEditingController(
                              text: question.points.toString());
                          return AlertDialog(
                            title: Text('Cambiar puntuación'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Puntuación actual: ${question.points} pts'),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: pointsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Nueva puntuación',
                                    hintText: 'Ej: 1000',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children:
                                      [500, 1000, 1500, 2000].map((points) {
                                    return ChoiceChip(
                                      label: Text('$points pts'),
                                      selected: false,
                                      onSelected: (_) {
                                        pointsController.text =
                                            points.toString();
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final newPoints =
                                      int.tryParse(pointsController.text) ??
                                          question.points;
                                  if (newPoints > 0) {
                                    kahootProvider.changeQuestionPoints(
                                        index, newPoints);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Puntuación actualizada a $newPoints puntos')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'La puntuación debe ser mayor a 0')),
                                    );
                                  }
                                },
                                child: Text('Guardar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }).toList(),
                onReorder: (oldIndex, newIndex) {
                  kahootProvider.reorderQuestions(oldIndex, newIndex);
                },
              )
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No hay preguntas. Añade una para comenzar.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            SizedBox(height: 24),

            // Estadísticas del Kahoot
            _buildKahootStats(kahootProvider),

            SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Añadir pregunta'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionTypeSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      CategoryProvider categoryProvider, KahootProvider kahootProvider) {
    if (categoryProvider.isLoading) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Categoría'),
        subtitle: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Cargando categorías...'),
          ],
        ),
      );
    }

    if (categoryProvider.error != null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Categoría'),
        subtitle: Text('Error al cargar categorías'),
        trailing: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => categoryProvider.loadCategories(),
        ),
      );
    }

    if (_selectedCategory == null && categoryProvider.categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedCategory = categoryProvider.categories.first;
        });
        kahootProvider.setCategory(categoryProvider.categories.first);
      });
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Categoría'),
      trailing: DropdownButton<String>(
        value: _selectedCategory,
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
          kahootProvider.setCategory(value!);
        },
        items: categoryProvider.categories
            .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCoverImageSection(MediaProvider mediaProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portada del Kahoot',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _selectedCoverLocalPath == null ? Colors.grey[200] : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedCoverLocalPath == null
                    ? Colors.grey[300]!
                    : Colors.transparent,
              ),
            ),
            child: _selectedCoverLocalPath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 50, color: Colors.grey[600]),
                      SizedBox(height: 12),
                      Text(
                        'Toca para añadir una imagen de portada',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 200,
                            maxWidth: double.infinity,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedCoverLocalPath!),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(Icons.broken_image,
                                        size: 50, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeCoverImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Imagen de portada',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_selectedCoverLocalPath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Nota: La imagen se ha guardado localmente y se usará para mostrar la portada',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKahootStats(KahootProvider kahootProvider) {
    final kahoot = kahootProvider.currentKahoot;
    int totalQuestions = kahoot.questions.length;
    int totalAnswers =
        kahoot.questions.fold(0, (sum, q) => sum + q.answers.length);
    int questionsWithMedia = kahoot.questions
        .where((q) => q.mediaId != null && q.mediaId!.isNotEmpty)
        .length;

    int answersWithMedia = 0;
    for (var question in kahoot.questions) {
      answersWithMedia += question.answers
          .where((a) => a.mediaId != null && a.mediaId!.isNotEmpty)
          .length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas del Kahoot',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                    Icons.quiz, 'Preguntas', totalQuestions.toString()),
                _buildStatItem(Icons.question_answer, 'Respuestas',
                    totalAnswers.toString()),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(Icons.image, 'Preguntas con multimedia',
                    questionsWithMedia.toString()),
                _buildStatItem(Icons.photo_library, 'Respuestas con multimedia',
                    answersWithMedia.toString()),
              ],
            ),
            if (_selectedCoverImageId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Portada con imagen personalizada',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
