import 'usuario.dart';

class LoginResponse {
  final String token;
  final int idUsuario;
  final String nombre;
  final String rol;

  LoginResponse({
    required this.token,
    required this.idUsuario,
    required this.nombre,
    required this.rol,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      rol: json['rol'],
    );
  }

  Usuario toUsuario() {
    return Usuario(
      idUsuario: idUsuario,
      nombre: nombre,
      rol: rol,
      activo: true,
    );
  }
}
