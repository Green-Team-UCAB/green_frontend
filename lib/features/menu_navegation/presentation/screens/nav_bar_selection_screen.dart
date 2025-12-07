import 'package:flutter/material.dart';
import 'package:green_frontend/core/theme/app_pallete.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/create_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/discover_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/home_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/join_sync_game_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/library_screen.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/menu_navegation/presentation/providers/navigation_provider.dart';


class NavBarSelectionScreen extends StatelessWidget{
  const NavBarSelectionScreen({super.key});

  final List<Widget> pages = const [
    HomeScreen(),      // Pantalla para "Inicio"
    DiscoverScreen(),  // Pantalla para "Descubre"
    JoinScreen(),      // Pantalla para "Unirse"
    CreateScreen(),    // Pantalla para "Crear"
    LibraryScreen(),   // Pantalla para "Biblioteca"
  ];
  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);  // Se accede al Provider

    return Scaffold(
      body: pages[navigationProvider.currentIndex],  // Muestra la página basada en el índice del Provider
      backgroundColor: AppPallete.backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppPallete.backgroundColor,
        currentIndex: navigationProvider.currentIndex,  // Usa el índice del Provider
        onTap: (index) {
          navigationProvider.updateIndex(index);  // Actualiza por el Provider
        },
        selectedItemColor: AppPallete.gradient1,
        unselectedItemColor: AppPallete.greyColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Descubre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Unirse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Crear',
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