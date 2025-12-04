class AppccFreidora {
  final int idAppccFreidora;
  final int idAppcc;
  final double? temperaturaFreidora1;
  final double? temperaturaFreidora2;
  final double? tpmFreidora1;
  final double? tpmFreidora2;
  final String? observaciones;

  AppccFreidora({
    required this.idAppccFreidora,
    required this.idAppcc,
    this.temperaturaFreidora1,
    this.temperaturaFreidora2,
    this.tpmFreidora1,
    this.tpmFreidora2,
    this.observaciones,
  });

  int get id => idAppccFreidora;

  int get camposCompletados {
    int count = 0;
    if (temperaturaFreidora1 != null) count++;
    if (temperaturaFreidora2 != null) count++;
    if (tpmFreidora1 != null) count++;
    if (tpmFreidora2 != null) count++;
    return count;
  }

  int get totalCampos => 4;

  factory AppccFreidora.fromJson(Map<String, dynamic> json) {
    return AppccFreidora(
      idAppccFreidora: json['id_appcc_freidora'] ?? 0,
      idAppcc: json['id_appcc'] ?? 0,
      temperaturaFreidora1: json['temperatura_freidora1']?.toDouble(),
      temperaturaFreidora2: json['temperatura_freidora2']?.toDouble(),
      tpmFreidora1: json['tpm_freidora1']?.toDouble(),
      tpmFreidora2: json['tpm_freidora2']?.toDouble(),
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_appcc_freidora': idAppccFreidora,
      'id_appcc': idAppcc,
      'temperatura_freidora1': temperaturaFreidora1,
      'temperatura_freidora2': temperaturaFreidora2,
      'tpm_freidora1': tpmFreidora1,
      'tpm_freidora2': tpmFreidora2,
      'observaciones': observaciones,
    };
  }
}
