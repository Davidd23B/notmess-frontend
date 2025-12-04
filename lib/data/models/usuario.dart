class Usuario {
  final int idUsuario;
  final String nombre;
  final String? passwd;
  final String rol;
  final bool activo;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    this.passwd,
    required this.rol,
    this.activo = true,
  });

  int get id => idUsuario;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'] ?? 0,
      nombre: json['nombre'] ?? '',
      rol: json['rol'] ?? 'usuario',
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      if (passwd != null) 'passwd': passwd,
      'rol': rol,
      'activo': activo,
    };
  }

  bool get isAdmin => rol.toLowerCase() == 'admin';
}
