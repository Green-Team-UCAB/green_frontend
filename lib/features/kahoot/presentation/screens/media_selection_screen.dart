import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/providers/theme_provider.dart';
import 'package:provider/provider.dart';


class MediaSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir multimedia'),
      ),
      body: Column(
        children: [
          // Opciones de carga
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.paste, color: Colors.purple),
                    title: Text('Pegar'),
                    onTap: () {
                      // Implementar pegado
                      // Por ahora,  regresara null 
                      Navigator.pop(context, null);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.photo_library, color: Colors.purple),
                    title: Text('Galería'),
                    onTap: () async {
                      // Aquí deberías abrir la galería del dispositivo
                      
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.camera_alt, color: Colors.purple),
                    title: Text('Cámara'),
                    onTap: () async {
                      // Aquí deberías abrir la cámara
                     
                      Navigator.pop(context, null);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Galería de imágenes disponibles
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Imágenes disponibles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: themeProvider.themes.length,
                      itemBuilder: (context, index) {
                        final theme = themeProvider.themes[index];
                        return GestureDetector(
                          onTap: () {
                            // Esto regresará el theme.id a la pantalla que llamó
                            Navigator.pop(context, theme.id);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              theme.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}