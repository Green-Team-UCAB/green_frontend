import 'package:flutter/material.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/theme_image.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/theme_provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';

class ThemeSelectionScreen extends StatefulWidget {
  @override
  _ThemeSelectionScreenState createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).loadThemes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Temas Kahoot!'),
      ),
      body: _buildBody(themeProvider, kahootProvider),
    );
  }

  Widget _buildBody(ThemeProvider themeProvider, KahootProvider kahootProvider) {
    if (themeProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (themeProvider.error != null) {
      return _buildErrorWidget(themeProvider);
    }

    if (themeProvider.themes.isEmpty) {
      return _buildEmptyWidget(themeProvider);
    }

    return _buildThemesGrid(themeProvider, kahootProvider);
  }

  Widget _buildErrorWidget(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            themeProvider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => themeProvider.loadThemes(),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hay temas disponibles'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => themeProvider.loadThemes(),
            child: Text('Cargar temas'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesGrid(ThemeProvider themeProvider, KahootProvider kahootProvider) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: themeProvider.themes.length,
      itemBuilder: (context, index) {
        final theme = themeProvider.themes[index];
        return _buildThemeCard(theme, kahootProvider);
      },
    );
  }

  Widget _buildThemeCard(ThemeImage theme, KahootProvider kahootProvider) {
    return GestureDetector(
      onTap: () {
        kahootProvider.setThemeId(theme.id);
        Navigator.pop(context);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  theme.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                theme.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}