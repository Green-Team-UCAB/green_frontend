import 'package:flutter/material.dart';


class KahootCreatorScreen extends StatefulWidget {
  const KahootCreatorScreen({super.key});

  @override
  State<KahootCreatorScreen> createState() => KahootEditorScreen();
}

class KahootEditorScreen extends State<KahootCreatorScreen> {
  String? valorVisibilidad;
  final List<String> _visibilidad = ['Publico', 'Privado'];

  void _showVisibilityOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visible para',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ..._visibilidad.map((option) {
                return ListTile(
                  title: Text(option),
                  trailing: valorVisibilidad == option
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      valorVisibilidad = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(),
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        title: Center(child: Text('Crear kahoot')),
        backgroundColor: Colors.grey,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alerta de preguntas
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asegúrate de que tus preguntas estén completas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Text('Reparar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Imagen de portada
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Lógica del botón
                    },
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    label: Text(
                      'Pulsa para añadir una imagen de portada',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Título
            Text(
              'Título',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Escribir título',
                ),
              ),
            ),

            SizedBox(height: 20),

            // Tema
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Estándar'), // aqui  va la interfaz Temas
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Visible para
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visible para',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: _showVisibilityOptions,
                        child: Text(
                          valorVisibilidad ?? 'Selecciona la visibilidad',
                          style: TextStyle(
                            color: valorVisibilidad != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showVisibilityOptions,
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),

            SizedBox(height: 24),

            // donde deben ir  las preguntas
            SizedBox(height: 24),

            // Botón añadir pregunta
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add),
                label: Text(
                  'Añadir pregunta',
                  style: TextStyle(color: Colors.black),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}