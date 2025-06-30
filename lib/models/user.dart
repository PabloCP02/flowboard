class User {
  // Atributos
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String password;
  final String confirmarPassword;
  
  // Constructor
  User ({
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.password,
    required this.confirmarPassword
  });

  // Método para convertir los atributos en formato JSON
  Map<String, dynamic> toJson()=>{
    "nombres" : nombres,
    "apellidoPaterno": apellidoPaterno,
    "apellidoMaterno": apellidoMaterno,
    "correo" : correo,
    "password" : password,
    "password_confirmation": confirmarPassword
  };
}