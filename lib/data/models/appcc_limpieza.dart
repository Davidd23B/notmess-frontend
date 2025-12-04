class AppccLimpieza {
  final int idAppccLimpieza;
  final int idAppcc;
  final bool? congelador1;
  final bool? congelador2;
  final bool? congelador3;
  final bool? camara1;
  final bool? camara2;
  final bool? mesa1;
  final bool? mesa2;
  final bool? mesa3;
  final bool? paredes;
  final bool? suelo;
  final String? observaciones;

  AppccLimpieza({
    required this.idAppccLimpieza,
    required this.idAppcc,
    this.congelador1,
    this.congelador2,
    this.congelador3,
    this.camara1,
    this.camara2,
    this.mesa1,
    this.mesa2,
    this.mesa3,
    this.paredes,
    this.suelo,
    this.observaciones,
  });

  int get id => idAppccLimpieza;

  factory AppccLimpieza.fromJson(Map<String, dynamic> json) {
    return AppccLimpieza(
      idAppccLimpieza: json['id_appcc_limpieza'] ?? 0,
      idAppcc: json['id_appcc'] ?? 0,
      congelador1: json['congelador1'],
      congelador2: json['congelador2'],
      congelador3: json['congelador3'],
      camara1: json['camara1'],
      camara2: json['camara2'],
      mesa1: json['mesa1'],
      mesa2: json['mesa2'],
      mesa3: json['mesa3'],
      paredes: json['paredes'],
      suelo: json['suelo'],
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_appcc_limpieza': idAppccLimpieza,
      'id_appcc': idAppcc,
      'congelador1': congelador1,
      'congelador2': congelador2,
      'congelador3': congelador3,
      'camara1': camara1,
      'camara2': camara2,
      'mesa1': mesa1,
      'mesa2': mesa2,
      'mesa3': mesa3,
      'paredes': paredes,
      'suelo': suelo,
      'observaciones': observaciones,
    };
  }

  int get camposCompletados {
    int completados = 0;
    if (congelador1 != null) completados++;
    if (congelador2 != null) completados++;
    if (congelador3 != null) completados++;
    if (camara1 != null) completados++;
    if (camara2 != null) completados++;
    if (mesa1 != null) completados++;
    if (mesa2 != null) completados++;
    if (mesa3 != null) completados++;
    if (paredes != null) completados++;
    if (suelo != null) completados++;
    return completados;
  }

  int get totalCampos => 10;
}
