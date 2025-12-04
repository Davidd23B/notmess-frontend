class Appcc {
  final int idAppcc;
  final DateTime fecha;
  final String turno; // mañana, tarde, noche.
  final bool completado;
  final String? observaciones;
  final int idUsuario;
  final String? nombreUsuario;

  Appcc({
    required this.idAppcc,
    required this.fecha,
    required this.turno,
    required this.completado,
    this.observaciones,
    required this.idUsuario,
    this.nombreUsuario,
  });

  int get id => idAppcc;

  factory Appcc.fromJson(Map<String, dynamic> json) {
    return Appcc(
      idAppcc: json['id_appcc'] ?? 0,
      fecha: json['fecha'] != null 
          ? _parseBackendDate(json['fecha']) 
          : DateTime.now(),
      turno: json['turno'] ?? 'mañana',
      completado: json['completado'] ?? false,
      observaciones: json['observaciones'],
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
    final timeStr = '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}:'
        '${fecha.second.toString().padLeft(2, '0')}';
    final dateStr = '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
    
    return {
      'id_appcc': idAppcc,
      'fecha': '$timeStr $dateStr',
      'turno': turno,
      'completado': completado,
      'observaciones': observaciones,
      'id_usuario': idUsuario,
    };
  }

  Appcc copyWith({
    int? idAppcc,
    DateTime? fecha,
    String? turno,
    bool? completado,
    String? observaciones,
    int? idUsuario,
    String? nombreUsuario,
  }) {
    return Appcc(
      idAppcc: idAppcc ?? this.idAppcc,
      fecha: fecha ?? this.fecha,
      turno: turno ?? this.turno,
      completado: completado ?? this.completado,
      observaciones: observaciones ?? this.observaciones,
      idUsuario: idUsuario ?? this.idUsuario,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
    );
  }
}
