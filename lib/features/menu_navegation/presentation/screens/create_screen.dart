import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/presentation/screens/create_kahoot_screen.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/development.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Creación del Kahoot',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateKahootScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.create_outlined, size: 40),
                SizedBox(height: 10),
                Text('Lienzo Blanco', style: TextStyle(fontSize: 18)),
                Text('Crea kahoot desde 0', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DesarrolloPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.layers_outlined, size: 40),
                SizedBox(height: 10),
                Text('Plantilla', style: TextStyle(fontSize: 18)),
                Text(
                  'Crea Kahoot a través ',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'de una plantilla ya existente',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}