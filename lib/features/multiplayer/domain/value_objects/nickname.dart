class Nickname { 
  final String value; 
  
  Nickname(this.value) { 
    if (value.length < 6 || value.length > 20) { 
      throw ArgumentError('Nickname debe tener entre 6 y 20 caracteres'); 
    } 
  } 
}