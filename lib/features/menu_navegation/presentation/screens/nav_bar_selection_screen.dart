import 'package:flutter/material.dart';
import 'package:green_frontend/core/theme/app_pallete.dart';

class NavBarSelectionScreen extends StatefulWidget{
  final int initialIndex;
  const NavBarSelectionScreen({super.key, this.initialIndex=0});

  @override
  State<NavBarSelectionScreen> createState() => _NavBarSelectionScreenState();

}
  class _NavBarSelectionScreenState extends State<NavBarSelectionScreen> {
  final PageStorageBucket bucket = PageStorageBucket();
    final pages =[
      Scaffold(
        body: Center(
          child: Text('Inicio'),
        ),
      ),
      Scaffold(
        body: Center(
          child: Text('Descubre'),
        ),
      ),
      Scaffold(
        body: Center(
          child: Text('Unirse')
        )
      ), 
      Scaffold(
        body: Center(
          child: Text('Crear')
        )
      ),
      Scaffold(
        body: Center(
          child: Text('Biblioteca')
        )
      ),
    ]; 
  
  late int selectedIndex;
  @override
  void initState(){
    selectedIndex = widget.initialIndex;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: bucket, child: pages[selectedIndex]),
      backgroundColor: AppPallete.backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppPallete.backgroundColor,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
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
        ],),
    );
  }
}
