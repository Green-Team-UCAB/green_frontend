import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/theme_provider.dart';

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
      body: themeProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : themeProvider.error != null
              ? Center(child: Text(themeProvider.error!))
              : GridView.builder(
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
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(theme.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                theme.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}