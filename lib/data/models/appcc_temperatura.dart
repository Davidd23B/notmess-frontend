class AppccTemperatura {
  final int idAppccTemperatura;
  final int idAppcc;
  final double? congelador1;
  final double? congelador2;
  final double? congelador3;
  final double? camara1;
  final double? camara2;
  final double? mesa1;
  final double? mesa2;
  final double? mesa3;
  final String? observaciones;

  AppccTemperatura({
    required this.idAppccTemperatura,
    required this.idAppcc,
    this.congelador1,
    this.congelador2,
    this.congelador3,
    this.camara1,
    this.camara2,
    this.mesa1,
    this.mesa2,
    this.mesa3,
    this.observaciones,
  });

  int get id => idAppccTemperatura;

  int get camposCompletados {
    int count = 0;
    if (congelador1 != null) count++;
    if (congelador2 != null) count++;
    if (congelador3 != null) count++;
    if (camara1 != null) count++;
    if (camara2 != null) count++;
    if (mesa1 != null) count++;
    if (mesa2 != null) count++;
    if (mesa3 != null) count++;
    return count;
  }

  int get totalCampos => 8;

  factory AppccTemperatura.fromJson(Map<String, dynamic> json) {
    return AppccTemperatura(
      idAppccTemperatura: json['id_appcc_temperatura'] ?? 0,
      idAppcc: json['id_appcc'] ?? 0,
      congelador1: json['congelador1']?.toDouble(),
      congelador2: json['congelador2']?.toDouble(),
      congelador3: json['congelador3']?.toDouble(),
      camara1: json['camara1']?.toDouble(),
      camara2: json['camara2']?.toDouble(),
      mesa1: json['mesa1']?.toDouble(),
      mesa2: json['mesa2']?.toDouble(),
      mesa3: json['mesa3']?.toDouble(),
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_appcc_temperatura': idAppccTemperatura,
      'id_appcc': idAppcc,
      'congelador1': congelador1,
      'congelador2': congelador2,
      'congelador3': congelador3,
      'camara1': camara1,
      'camara2': camara2,
      'mesa1': mesa1,
      'mesa2': mesa2,
      'mesa3': mesa3,
      'observaciones': observaciones,
    };
  }
}
