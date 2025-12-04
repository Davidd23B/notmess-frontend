class Albaran {
  final int idAlbaran;
  final String tipo; // entrada, salida, merma.
  final DateTime fechaHora;
  final String? observaciones;
  final String? motivoMerma;
  final int idUsuario;
  final String? nombreUsuario;

  Albaran({
    required this.idAlbaran,
    required this.tipo,
    required this.fechaHora,
    this.observaciones,
    this.motivoMerma,
    required this.idUsuario,
    this.nombreUsuario,
  });

  int get id => idAlbaran;
  DateTime get fecha => fechaHora;

  factory Albaran.fromJson(Map<String, dynamic> json) {
    return Albaran(
      idAlbaran: json['id_albaran'] ?? 0,
      tipo: json['tipo'] ?? 'entrada',
      fechaHora: json['fechaHora'] != null 
          ? _parseBackendDate(json['fechaHora'])
          : DateTime.now(),
      observaciones: json['observaciones'],
      motivoMerma: json['motivo_merma'],
      idUsuario: json['id_usuario'] ?? 0,
      nombreUsuario: json['nombre_usuario'],
    );
  }

  static DateTime _parseBackendDate(String dateStr) {
    try {
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr);
      }
      final parts = dateStr.split(' ');
      if (parts.length != 2) return DateTime.now();
      
      final timeParts = parts[0].split(':');
      final dateParts = parts[1].split('/');
      
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    final timeStr = '${fechaHora.hour.toString().padLeft(2, '0')}:'
        '${fechaHora.minute.toString().padLeft(2, '0')}:'
        '${fechaHora.second.toString().padLeft(2, '0')}';
    final dateStr = '${fechaHora.day.toString().padLeft(2, '0')}/'
        '${fechaHora.month.toString().padLeft(2, '0')}/'
        '${fechaHora.year}';
    
    return {
      'id_albaran': idAlbaran,
      'tipo': tipo,
      'fechaHora': '$timeStr $dateStr',
      if (observaciones != null) 'observaciones': observaciones,
      if (motivoMerma != null) 'motivo_merma': motivoMerma,
      'id_usuario': idUsuario,
    };
  }

  String get tipoFormateado {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return 'Entrada';
      case 'salida':
        return 'Salida';
      case 'merma':
        return 'Merma';
      default:
        return tipo;
    }
  }
}
