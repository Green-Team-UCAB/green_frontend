import 'package:flutter/material.dart';
// Importamos TU página de biblioteca (que ya tiene los tabs y reportes)
import '../../../library/presentation/pages/library_page.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí "enchufamos" tu funcionalidad
    return const LibraryPage();
  }
}
