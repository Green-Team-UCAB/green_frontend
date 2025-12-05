import 'package:flutter/material.dart';

class DesarrolloPage extends StatelessWidget {
  const DesarrolloPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con botón de regreso
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Próximamente'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        shadowColor: Colors.blueAccent.withOpacity(0.3),
      ),

      // Cuerpo principal
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono decorativo
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 80,
                  color: Colors.blueAccent.withOpacity(0.7),
                ),
              ),

              // Texto principal
              const Text(
                'En desarrollo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                  letterSpacing: 1.2,
                ),
              ),

              // Subtítulo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Text(
                  'Esta funcionalidad estará disponible próximamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),

              // Separador
              const SizedBox(height: 40),

              // Botón adicional para regresar (opcional)
            ],
          ),
        ),
      ),

      // Fondo degradado opcional (ya está en el body)
    );
  }
}
