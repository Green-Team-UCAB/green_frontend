class TimeElapsedMs { 
  final int value; 
  TimeElapsedMs(this.value) { 
    if (value < 0) throw ArgumentError('Tiempo transcurrido no puede ser negativo'); 
  } 
}