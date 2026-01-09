class QrToken { 
  final String value;  
  QrToken(this.value) { 
    if (value.isEmpty) throw ArgumentError('QR token vacío'); 
  } 
}