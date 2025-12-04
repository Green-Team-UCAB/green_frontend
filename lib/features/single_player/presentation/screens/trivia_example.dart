import 'dart:async';  // Necesario para Timer
import 'package:flutter/material.dart';

class TriviaScreen extends StatefulWidget {
  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  // Datos de ejemplo
  final String question = "¿Cuál es la capital de Francia?";
  final List<String> options = ["París", "Madrid", "Roma", "Berlín"];
  final int correctAnswerIndex = 0;
  final String? imageUrl = null;

  int? selectedIndex;
  int remainingTime = 30;  // Tiempo inicial en segundos
  Timer? _timer;  // Timer para el conteo

  @override
  void initState() {
    super.initState();
    _startTimer();  // Iniciar el temporizador al cargar la pantalla
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancelar el timer al salir
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          _timer?.cancel();  // Detener cuando llegue a 0
        }
      });
    });
  }

  void _selectAnswer(int index) {
    if (remainingTime > 0) {  // Solo permitir selección si hay tiempo
      setState(() {
        selectedIndex = index;
      });
      _timer?.cancel();  // Detener el timer al seleccionar
      // Aquí puedes agregar lógica para verificar respuesta y navegar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Juego de Trivia"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Temporizador
            Text(
              "Tiempo restante: $remainingTime segundos",
              style: TextStyle(fontSize: 20, color: remainingTime > 10 ? Colors.black : Colors.red),
            ),
            SizedBox(height: 20),
            
            // Imagen opcional
            if (imageUrl != null)
              Image.network(imageUrl!, height: 150, fit: BoxFit.cover)
            else
              Container(
                height: 150,
                color: Colors.grey[300],
                child: Center(child: Text("Sin imagen")),
              ),
            SizedBox(height: 20),
            
            // Pregunta
            Text(
              question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Opciones de respuesta
            ...List.generate(options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: (selectedIndex == null && remainingTime > 0) ? () => _selectAnswer(index) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedIndex == null
                        ? Colors.blue
                        : (index == correctAnswerIndex ? Colors.green : (selectedIndex == index ? Colors.red : Colors.grey)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(options[index], style: TextStyle(fontSize: 18)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}