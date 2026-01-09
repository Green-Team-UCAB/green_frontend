class SessionPin { 
  final String value; 
  SessionPin(this.value) { 
    if (value.isEmpty || value.length < 6 || value.length > 10) { 
      throw ArgumentError('PIN inválido: debe tener entre 6 y 10 dígitos'); 
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) { 
      throw ArgumentError('PIN inválido: solo dígitos'); 
    } 
  } 
}