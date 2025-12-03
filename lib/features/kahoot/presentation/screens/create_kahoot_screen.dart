import 'package:flutter/material.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/question.dart';
import 'package:kahoot_project/features/kahoot/presentation/screens/normal_question_screen.dart';
import 'package:kahoot_project/features/kahoot/presentation/screens/true_false_question_screen.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';
import 'theme_selection_screen.dart';
import 'question_type_selection_screen.dart';
import 'package:kahoot_project/features/kahoot/presentation/widgets/question_tile.dart';

class CreateKahootScreen extends StatefulWidget {
  @override
  _CreateKahootScreenState createState() => _CreateKahootScreenState();
}

class _CreateKahootScreenState extends State<CreateKahootScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedVisibility = 'private';
  String? _selectedCategory;
  List<String> _categories = [
    'Matemáticas',
    'Ciencias',
    'Historia',
    'Geografía',
    'Idiomas',
    'Arte',
    'Tecnología',
    'Deportes'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final kahootProvider = Provider.of<KahootProvider>(context);
    final currentTheme = kahootProvider.currentKahoot.themeId.isNotEmpty
        ? 'Tema seleccionado'
        : 'Seleccionar tema';
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
              
              if (kahootProvider.currentKahoot.questions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Debe agregar al menos una pregunta')),
                );
                return;
              }
              
              await kahootProvider.saveKahoot();
              if (kahootProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kahoot guardado exitosamente')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(kahootProvider.error!)),
                );
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
                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Tema'),
              subtitle: Text(currentTheme),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThemeSelectionScreen()),
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
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
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
            ...kahootProvider.currentKahoot.questions.asMap().entries.map((entry) {
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
                  kahootProvider.removeQuestion(index);
                },
              );
            }).toList(),
            SizedBox(height: 24),
            // Botón para añadir pregunta
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