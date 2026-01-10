import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/domain/entities/theme_image.dart';
import 'package:green_frontend/features/kahoot/presentation/screens/question_type_selection_screen.dart';
import 'package:green_frontend/features/kahoot/presentation/widgets/question_tile.dart';
import 'package:provider/provider.dart';
import 'theme_selection_screen.dart';
import '../../application/providers/kahoot_provider.dart';
import '../../application/providers/theme_provider.dart';

import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'normal_question_screen.dart';
import 'true_false_question_screen.dart';

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

  final List<String> _categories = [
    'Matemáticas',
    'Ciencias',
    'Historia',
    'Geografía',
    'Idiomas',
    'Arte',
    'Tecnología',
    'Deportes',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeProvider.themes.isEmpty) {
        themeProvider.loadThemes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kahootProvider = Provider.of<KahootProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

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
            // Portada
            GestureDetector(
              onTap: () {
                // Implementar selección de imagen de portada
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pulsa para añadir una imagen de portada',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
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
                        // _selectedThemeId eliminado por no uso
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

            // Categoría
            ListTile(
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
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
              ),
            ),
            Divider(),

            // Preguntas
            Text(
              'Preguntas (${kahootProvider.currentKahoot.questions.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            if (kahootProvider.currentKahoot.questions.isNotEmpty)
              ...kahootProvider.currentKahoot.questions.asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final question = entry.value;
                return QuestionTile(
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
                    } else if (question.type == QuestionType.trueFalse) {
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
                          '¿Estás seguro de que quieres eliminar esta pregunta?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              kahootProvider.removeQuestion(index);
                              Navigator.pop(context);
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
                );
              }).toList()
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
}
