class Producto {
  final int idProducto;
  final String nombre;
  final double cantidad;
  final String medida; // 'unidad', 'kg', 'L'
  final String proveedor;
  final String? imagen;
  final int idCategoria;
  final String? nombreCategoria; // Para mostrar en UI

  Producto({
    required this.idProducto,
    required this.nombre,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
    this.imagen,
    required this.idCategoria,
    this.nombreCategoria,
  });

  // Getter para compatibilidad
  int get id => idProducto;

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'] ?? 0,
      nombre: json['nombre'] ?? '',
      cantidad: (json['cantidad'] as num?)?.toDouble() ?? 0.0,
      medida: json['medida'] ?? 'unidad',
      proveedor: json['proveedor'] ?? '',
      imagen: json['imagen'],
      idCategoria: json['id_categoria'] ?? 0,
      nombreCategoria: json['nombre_categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'nombre': nombre,
      'cantidad': cantidad,
      'medida': medida,
      'proveedor': proveedor,
      'imagen': imagen,
      'id_categoria': idCategoria,
    };
  }

  String get cantidadFormateada {
    if (medida == 'unidad') {
      return '${cantidad.toInt()} uds';
    } else if (medida == 'kg') {
      return '${cantidad.toStringAsFixed(2)} kg';
    } else if (medida == 'L') {
      return '${cantidad.toStringAsFixed(2)} L';
    }
    return cantidad.toString();
  }
}
