class User {
  final String id;
  final String userName; 
  final String name;     
  final String email;
  final String type;    
  final DateTime createdAt;
  
  
  final String? description;
  final String? avatarAssetUrl; 

  User({
    required this.id,
    required this.userName,
    required this.name,      
    required this.email,
    required this.type,      
    required this.createdAt,
    this.description,
    this.avatarAssetUrl,     
  });
}