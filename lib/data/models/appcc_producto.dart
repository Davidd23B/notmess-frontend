class AppccProducto {
  final int idAppccProducto;
  final int idAppcc;
  final String? estadoProductoCongelador1;
  final String? estadoProductoCongelador2;
  final String? estadoProductoCongelador3;
  final String? estadoProductoCamara1;
  final String? estadoProductoCamara2;
  final String? estadoProductoMesa1;
  final String? estadoProductoMesa2;
  final String? estadoProductoMesa3;
  final double? temperaturaProductoCongelador1;
  final double? temperaturaProductoCongelador2;
  final double? temperaturaProductoCongelador3;
  final double? temperaturaProductoCamara1;
  final double? temperaturaProductoCamara2;
  final double? temperaturaProductoMesa1;
  final double? temperaturaProductoMesa2;
  final double? temperaturaProductoMesa3;
  final String? observaciones;

  AppccProducto({
    required this.idAppccProducto,
    required this.idAppcc,
    this.estadoProductoCongelador1,
    this.estadoProductoCongelador2,
    this.estadoProductoCongelador3,
    this.estadoProductoCamara1,
    this.estadoProductoCamara2,
    this.estadoProductoMesa1,
    this.estadoProductoMesa2,
    this.estadoProductoMesa3,
    this.temperaturaProductoCongelador1,
    this.temperaturaProductoCongelador2,
    this.temperaturaProductoCongelador3,
    this.temperaturaProductoCamara1,
    this.temperaturaProductoCamara2,
    this.temperaturaProductoMesa1,
    this.temperaturaProductoMesa2,
    this.temperaturaProductoMesa3,
    this.observaciones,
  });

  int get id => idAppccProducto;

  int get camposCompletados {
    int count = 0;
    if (estadoProductoCongelador1 != null) count++;
    if (estadoProductoCongelador2 != null) count++;
    if (estadoProductoCongelador3 != null) count++;
    if (estadoProductoCamara1 != null) count++;
    if (estadoProductoCamara2 != null) count++;
    if (estadoProductoMesa1 != null) count++;
    if (estadoProductoMesa2 != null) count++;
    if (estadoProductoMesa3 != null) count++;
    if (temperaturaProductoCongelador1 != null) count++;
    if (temperaturaProductoCongelador2 != null) count++;
    if (temperaturaProductoCongelador3 != null) count++;
    if (temperaturaProductoCamara1 != null) count++;
    if (temperaturaProductoCamara2 != null) count++;
    if (temperaturaProductoMesa1 != null) count++;
    if (temperaturaProductoMesa2 != null) count++;
    if (temperaturaProductoMesa3 != null) count++;
    return count;
  }

  int get totalCampos => 16;

  factory AppccProducto.fromJson(Map<String, dynamic> json) {
    return AppccProducto(
      idAppccProducto: json['id_appcc_producto'] ?? 0,
      idAppcc: json['id_appcc'] ?? 0,
      estadoProductoCongelador1: json['estado_producto_congelador1'],
      estadoProductoCongelador2: json['estado_producto_congelador2'],
      estadoProductoCongelador3: json['estado_producto_congelador3'],
      estadoProductoCamara1: json['estado_producto_camara1'],
      estadoProductoCamara2: json['estado_producto_camara2'],
      estadoProductoMesa1: json['estado_producto_mesa1'],
      estadoProductoMesa2: json['estado_producto_mesa2'],
      estadoProductoMesa3: json['estado_producto_mesa3'],
      temperaturaProductoCongelador1: json['temperatura_producto_congelador1']?.toDouble(),
      temperaturaProductoCongelador2: json['temperatura_producto_congelador2']?.toDouble(),
      temperaturaProductoCongelador3: json['temperatura_producto_congelador3']?.toDouble(),
      temperaturaProductoCamara1: json['temperatura_producto_camara1']?.toDouble(),
      temperaturaProductoCamara2: json['temperatura_producto_camara2']?.toDouble(),
      temperaturaProductoMesa1: json['temperatura_producto_mesa1']?.toDouble(),
      temperaturaProductoMesa2: json['temperatura_producto_mesa2']?.toDouble(),
      temperaturaProductoMesa3: json['temperatura_producto_mesa3']?.toDouble(),
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_appcc_producto': idAppccProducto,
      'id_appcc': idAppcc,
      'estado_producto_congelador1': estadoProductoCongelador1,
      'estado_producto_congelador2': estadoProductoCongelador2,
      'estado_producto_congelador3': estadoProductoCongelador3,
      'estado_producto_camara1': estadoProductoCamara1,
      'estado_producto_camara2': estadoProductoCamara2,
      'estado_producto_mesa1': estadoProductoMesa1,
      'estado_producto_mesa2': estadoProductoMesa2,
      'estado_producto_mesa3': estadoProductoMesa3,
      'temperatura_producto_congelador1': temperaturaProductoCongelador1,
      'temperatura_producto_congelador2': temperaturaProductoCongelador2,
      'temperatura_producto_congelador3': temperaturaProductoCongelador3,
      'temperatura_producto_camara1': temperaturaProductoCamara1,
      'temperatura_producto_camara2': temperaturaProductoCamara2,
      'temperatura_producto_mesa1': temperaturaProductoMesa1,
      'temperatura_producto_mesa2': temperaturaProductoMesa2,
      'temperatura_producto_mesa3': temperaturaProductoMesa3,
      'observaciones': observaciones,
    };
  }
}
