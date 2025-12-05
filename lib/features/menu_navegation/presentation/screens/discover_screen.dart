import 'package:flutter/material.dart';
// Importamos TU página de búsqueda
import '../../../discovery/presentation/pages/discovery_page.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí "enchufamos" tu funcionalidad
    return const DiscoveryPage();
  }
}
