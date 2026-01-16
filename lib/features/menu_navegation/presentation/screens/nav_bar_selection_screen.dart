import 'package:flutter/material.dart';
import 'package:green_frontend/core/theme/app_pallete.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/menu_navegation/presentation/providers/navigation_provider.dart';

// --- Tus pantallas existentes ---
import 'package:green_frontend/features/menu_navegation/presentation/screens/create_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/discover_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/home_screen.dart';
import 'package:green_frontend/features/multiplayer/presentation/screens/join_game_page.dart';
import 'package:green_frontend/features/library/presentation/pages/library_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/injection_container.dart';

class NavBarSelectionScreen extends StatelessWidget {
   NavBarSelectionScreen({super.key});

  // Lista actualizada: Solo 5 pantallas
  final List<Widget> pages = [
     // 0: Inicio
    DiscoverScreen(), // 1: Descubre
    CreateScreen(), // 3: Crear
    BlocProvider(
    create: (_) => sl<MultiplayerBloc>(),
    child: const JoinGameScreen(),
  ),
    LibraryPage(), // 4: Biblioteca (El nuevo Hub Principal)
    ProfileScreen(), //Perfil de usuario
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      // IndexedStack mantiene el estado de las páginas (no recargan al cambiar de tab)
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: pages,
      ),

      backgroundColor: AppPallete.backgroundColor,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Labels siempre visibles
        backgroundColor: AppPallete.backgroundColor,
        currentIndex: navigationProvider.currentIndex,
        onTap: (index) {
          navigationProvider.updateIndex(index);
        },
        selectedItemColor: AppPallete.gradient1,
        unselectedItemColor: AppPallete.greyColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,

        // Lista actualizada: Solo 5 ítems
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Crear',
          ),

          // Botón central "Unirse" destacado (Opcional: puedes personalizarlo más si quieres)
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                // Un pequeño fondo para destacar "Unirse" si lo deseas, o déjalo simple
                color: navigationProvider.currentIndex == 2
                    ? AppPallete.gradient1.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sports_esports),
            ),
            label: 'Unirse',
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'Biblioteca',
          ),

          // "Grupos" ELIMINADO ❌
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Icono de usuario/biblioteca
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
