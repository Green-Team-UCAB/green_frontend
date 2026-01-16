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
import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';

class EditKahootScreen extends StatefulWidget {
  final Kahoot kahootToEdit;

  const EditKahootScreen({Key? key, required this.kahootToEdit}) : super(key: key);

  @override
  _EditKahootScreenState createState() => _EditKahootScreenState();
}

class _EditKahootScreenState extends State<EditKahootScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedVisibility;
  String? _selectedCategory;
  String? _selectedThemeName = 'Seleccionar tema';
  String? _selectedThemeId = '';
  String? _selectedCoverImageId;
  String? _selectedCoverLocalPath;
  bool _isLoadingTheme = false;

  @override
  void initState() {
    super.initState();
    
    _selectedVisibility = 'private';
    _selectedCategory = widget.kahootToEdit.category;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKahootData();
    });
  }

  Future<void> _loadKahootData() async {
    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    
    try {
      if (widget.kahootToEdit.id != null && widget.kahootToEdit.id!.isNotEmpty) {
        await kahootProvider.loadFullKahoot(widget.kahootToEdit.id!);
      } else {
        kahootProvider.loadKahoot(widget.kahootToEdit);
      }
      
      await _initializeControls(kahootProvider, mediaProvider);
      
    } catch (e) {
      kahootProvider.loadKahoot(widget.kahootToEdit);
      await _initializeControls(kahootProvider, mediaProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo cargar el kahoot completo. Editando con datos básicos.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    
    await _loadAdditionalData();
  }

  Future<void> _initializeControls(KahootProvider kahootProvider, MediaProvider mediaProvider) async {
    final currentKahoot = kahootProvider.currentKahoot;
    
    _titleController.text = currentKahoot.title;
    _descriptionController.text = currentKahoot.description ?? '';
    
    final visibilityValue = currentKahoot.visibility ?? 'private';
    _selectedVisibility = visibilityValue.toLowerCase();
    
    _selectedThemeId = currentKahoot.themeId;
    _selectedCoverImageId = currentKahoot.coverImageId;
    
    if (_selectedCoverImageId != null && _selectedCoverImageId!.isNotEmpty) {
      final localPath = mediaProvider.getLocalPath(_selectedCoverImageId!);
      
      if (localPath != null && await File(localPath).exists()) {
        setState(() {
          _selectedCoverLocalPath = localPath;
        });
      } else {
        setState(() {
          _selectedCoverLocalPath = null;
        });
      }
    } else {
      setState(() {
        _selectedCoverLocalPath = null;
      });
    }
  }

  Future<void> _loadAdditionalData() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    setState(() {
      _isLoadingTheme = true;
    });

    try {
      if (themeProvider.themes.isEmpty) {
        await themeProvider.loadThemes();
      }

      if (categoryProvider.categories.isEmpty) {
        await categoryProvider.loadCategories();
      }

      if (_selectedThemeId != null && _selectedThemeId!.isNotEmpty) {
        final currentTheme = themeProvider.themes.firstWhere(
          (theme) => theme.id == _selectedThemeId,
          orElse: () => ThemeImage(
            id: '',
            name: 'Tema no encontrado',
            imageUrl: '',
          ),
        );
        
        if (currentTheme.id.isNotEmpty) {
          setState(() {
            _selectedThemeName = currentTheme.name;
          });
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTheme = false;
        });
      }
    }
  }

  Future<void> _pickCoverImage() async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    try {
      final media = await mediaProvider.pickImageFromGallery();
      if (media != null) {
        setState(() {
          _selectedCoverImageId = media.id;
          _selectedCoverLocalPath = media.localPath;
        });

        final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
        kahootProvider.setCoverImageId(media.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen de portada actualizada correctamente')),
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
        title: Text('Editar Kahoot'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              final validationError = kahootProvider.validate();
              if (validationError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(validationError)),
                );
                return;
              }

              await kahootProvider.saveKahoot();
              if (!mounted) return;
              if (kahootProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kahoot actualizado exitosamente')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(kahootProvider.error!)),
                );
              }
            },
          ),
        ],
      ),
      body: kahootProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kahootProvider.error != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              kahootProvider.error!,
                              style: TextStyle(color: Colors.orange[800]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _buildCoverImageSection(mediaProvider),

                  SizedBox(height: 24),

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

                  StatefulBuilder(
                    builder: (context, setState) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Tema'),
                        subtitle: _isLoadingTheme
                            ? Text('Cargando...')
                            : Text(_selectedThemeName!),
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

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Visible para'),
                    trailing: DropdownButton<String>(
                      value: _selectedVisibility?.toLowerCase(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVisibility = value;
                          });
                          kahootProvider.setVisibility(value);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'public',
                          child: Text('Público'),
                        ),
                        DropdownMenuItem(
                          value: 'private',
                          child: Text('Privado'),
                        ),
                      ],
                    ),
                  ),
                  Divider(),

                  _buildCategorySection(categoryProvider, kahootProvider),
                  Divider(),

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
                      children: kahootProvider.currentKahoot.questions.asMap().entries.map((entry) {
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
                                        SnackBar(content: Text('Pregunta eliminada correctamente')),
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
                          onDuplicate: () {
                            kahootProvider.duplicateQuestion(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pregunta duplicada correctamente')),
                            );
                          },
                          onChangePoints: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final pointsController = TextEditingController(
                                  text: question.points.toString()
                                );
                                return AlertDialog(
                                  title: Text('Cambiar puntuación'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Puntuación actual: ${question.points} pts'),
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
                                        children: [500, 1000, 1500, 2000].map((points) {
                                          return ChoiceChip(
                                            label: Text('$points pts'),
                                            selected: false,
                                            onSelected: (_) {
                                              pointsController.text = points.toString();
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
                                        final newPoints = int.tryParse(pointsController.text) ?? question.points;
                                        if (newPoints > 0) {
                                          kahootProvider.changeQuestionPoints(index, newPoints);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Puntuación actualizada a $newPoints puntos')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('La puntuación debe ser mayor a 0')),
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

    String? normalizedCategory = _selectedCategory;
    if (normalizedCategory != null && categoryProvider.categories.isNotEmpty) {
      final exactMatch = categoryProvider.categories.firstWhere(
        (cat) => cat.toLowerCase() == normalizedCategory!.toLowerCase(),
        orElse: () => '',
      );
      
      if (exactMatch.isEmpty) {
        normalizedCategory = categoryProvider.categories.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedCategory = normalizedCategory;
          });
          kahootProvider.setCategory(normalizedCategory!);
        });
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Categoría'),
      trailing: DropdownButton<String>(
        value: normalizedCategory,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCategory = value;
            });
            kahootProvider.setCategory(value);
          }
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
                        'Toca para añadir/actualizar imagen de portada',
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