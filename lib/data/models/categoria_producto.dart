class CategoriaProducto {
  final int idCategoria;
  final String nombre;

  CategoriaProducto({
    required this.idCategoria,
    required this.nombre,
  });

  int get id => idCategoria;

  factory CategoriaProducto.fromJson(Map<String, dynamic> json) {
    return CategoriaProducto(
      idCategoria: json['id_categoria'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'nombre': nombre,
    };
    if (idCategoria != 0) {
      json['id_categoria'] = idCategoria;
    }
    return json;
  }
}
