import 'package:flutter/material.dart';
import 'package:green_frontend/core/theme/app_pallete.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/menu_navegation/presentation/providers/navigation_provider.dart';

// --- Tus pantallas existentes ---
import 'package:green_frontend/features/menu_navegation/presentation/screens/create_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/discover_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/home_screen.dart'; // Asumo que aquí está KahootLibraryScreen
import 'package:green_frontend/features/menu_navegation/presentation/screens/join_sync_game_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/library_screen.dart';

// --- ✅ NUEVA IMPORTACIÓN (Asegúrate de que la ruta sea correcta) ---
import '../../../groups/presentation/pages/groups_list_page.dart';

class NavBarSelectionScreen extends StatelessWidget {
  const NavBarSelectionScreen({super.key});

  // Agregamos GroupsListPage a la lista de páginas
  final List<Widget> pages = const [
    KahootLibraryScreen(), // 0: Inicio
    DiscoverScreen(), // 1: Descubre
    JoinScreen(), // 2: Unirse
    CreateScreen(), // 3: Crear
    GroupsListPage(), // 4: Grupos (✅ NUEVA)
    LibraryScreen(), // 5: Biblioteca
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      // ✅ USAMOS INDEXED STACK: Esto evita que la pantalla se recargue desde cero
      // cada vez que cambias de pestaña (vital para mantener los datos Mock cargados).
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: pages,
      ),

      backgroundColor: AppPallete.backgroundColor,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Mantiene los labels visibles
        backgroundColor: AppPallete.backgroundColor,
        currentIndex: navigationProvider.currentIndex,
        onTap: (index) {
          navigationProvider.updateIndex(index);
        },
        selectedItemColor: AppPallete.gradient1, // Tu color morado/azul
        unselectedItemColor: AppPallete.greyColor,
        selectedFontSize: 12, // Ajuste para que quepan 6 items
        unselectedFontSize: 12,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Descubre'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Unirse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Crear',
          ),
          // ✅ NUEVO ÍTEM DE NAVEGACIÓN
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined), // Icono perfecto para grupos
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'Biblioteca',
          ),
        ],
      ),
    );
  }
}
