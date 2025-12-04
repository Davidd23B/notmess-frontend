class LineaAlbaran {
  final int? idLineaAlbaran;
  final double cantidad;
  final int idAlbaran;
  final int idProducto;
  final String? nombreProducto;
  final String? imagenProducto;

  LineaAlbaran({
    this.idLineaAlbaran,
    required this.cantidad,
    required this.idAlbaran,
    required this.idProducto,
    this.nombreProducto,
    this.imagenProducto,
  });

  factory LineaAlbaran.fromJson(Map<String, dynamic> json) {
    return LineaAlbaran(
      idLineaAlbaran: json['id_linea_albaran'],
      cantidad: (json['cantidad'] as num).toDouble(),
      idAlbaran: json['id_albaran'],
      idProducto: json['id_producto'],
      nombreProducto: json['nombre_producto'],
      imagenProducto: json['imagen_producto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idLineaAlbaran != null) 'id_linea_albaran': idLineaAlbaran,
      'cantidad': cantidad,
      'id_albaran': idAlbaran,
      'id_producto': idProducto,
    };
  }
}
