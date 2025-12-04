import 'package:flutter/material.dart';
import '../../data/models/appcc.dart';
import '../../data/models/appcc_limpieza.dart';
import '../../data/models/appcc_temperatura.dart';
import '../../data/models/appcc_producto.dart';
import '../../data/models/appcc_freidora.dart';
import '../../data/services/appcc_service.dart';

class AppccViewModel extends ChangeNotifier {
  final AppccService _appccService = AppccService();

  List<Appcc> _appccListCompleta = []; // Lista completa sin filtrar
  List<Appcc> _appccList = []; // Lista filtrada
  bool _isLoading = false;
  String? _turnoFiltro;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  List<Appcc> get appccList => _appccList;
  bool get isLoading => _isLoading;
  String? get turnoFiltro => _turnoFiltro;
  DateTime? get fechaDesde => _fechaDesde;
  DateTime? get fechaHasta => _fechaHasta;

  // Cargar lista de APPCC
  Future<void> loadAppccList() async {
    _isLoading = true;
    notifyListeners();

    try {
      _appccListCompleta = await _appccService.getAppccList();
      _aplicarFiltros();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrar por turno
  void filtrarPorTurno(String? turno) {
    _turnoFiltro = turno;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    List<Appcc> listaFiltrada = List.from(_appccListCompleta);

    // Filtrar por turno
    if (_turnoFiltro != null && _turnoFiltro!.isNotEmpty) {
      listaFiltrada = listaFiltrada
          .where((appcc) => appcc.turno == _turnoFiltro)
          .toList();
    }

    // Filtrar por rango de fechas
    if (_fechaDesde != null) {
      final fechaDesdeSinHora = DateTime(_fechaDesde!.year, _fechaDesde!.month, _fechaDesde!.day);
      listaFiltrada = listaFiltrada
          .where((appcc) {
            final fechaAppcc = DateTime(appcc.fecha.year, appcc.fecha.month, appcc.fecha.day);
            return !fechaAppcc.isBefore(fechaDesdeSinHora);
          })
          .toList();
    }

    if (_fechaHasta != null) {
      final fechaHastaSinHora = DateTime(_fechaHasta!.year, _fechaHasta!.month, _fechaHasta!.day, 23, 59, 59);
      listaFiltrada = listaFiltrada
          .where((appcc) => !appcc.fecha.isAfter(fechaHastaSinHora))
          .toList();
    }

    // Ordenar por fecha descendente
    listaFiltrada.sort((a, b) => b.fecha.compareTo(a.fecha));
    
    _appccList = listaFiltrada;
    notifyListeners();
  }

  void setFechaDesde(DateTime? fecha) {
    _fechaDesde = fecha;
    _aplicarFiltros();
  }

  void setFechaHasta(DateTime? fecha) {
    _fechaHasta = fecha;
    _aplicarFiltros();
  }

  void clearFiltrosFecha() {
    _fechaDesde = null;
    _fechaHasta = null;
    _aplicarFiltros();
  }

  void limpiarFiltros() {
    _turnoFiltro = null;
    _fechaDesde = null;
    _fechaHasta = null;
    _aplicarFiltros();
  }

  Future<bool> createAppccCompleto({
    required String turno,
    required String? observacionesGenerales,
    required bool completado,
    required int idUsuario,
    required Map<String, bool?> limpieza,
    required String? observacionesLimpieza,
    required Map<String, double?> temperatura,
    required String? observacionesTemperatura,
    required Map<String, dynamic> producto,
    required String? observacionesProducto,
    required Map<String, double?> freidora,
    required String? observacionesFreidora,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final appcc = Appcc(
        idAppcc: 0,
        fecha: DateTime.now(),
        turno: turno,
        completado: completado,
        observaciones: observacionesGenerales,
        idUsuario: idUsuario,
      );

      final appccCreado = await _appccService.createAppcc(appcc);
      final idAppcc = appccCreado.idAppcc;

      final appccLimpieza = AppccLimpieza(
        idAppccLimpieza: 0,
        idAppcc: idAppcc,
        congelador1: limpieza['congelador1'],
        congelador2: limpieza['congelador2'],
        congelador3: limpieza['congelador3'],
        camara1: limpieza['camara1'],
        camara2: limpieza['camara2'],
        mesa1: limpieza['mesa1'],
        mesa2: limpieza['mesa2'],
        mesa3: limpieza['mesa3'],
        paredes: limpieza['paredes'],
        suelo: limpieza['suelo'],
        observaciones: observacionesLimpieza,
      );
      await _appccService.createLimpieza(appccLimpieza);

      final appccTemperatura = AppccTemperatura(
        idAppccTemperatura: 0,
        idAppcc: idAppcc,
        congelador1: temperatura['congelador1'],
        congelador2: temperatura['congelador2'],
        congelador3: temperatura['congelador3'],
        camara1: temperatura['camara1'],
        camara2: temperatura['camara2'],
        mesa1: temperatura['mesa1'],
        mesa2: temperatura['mesa2'],
        mesa3: temperatura['mesa3'],
        observaciones: observacionesTemperatura,
      );
      await _appccService.createTemperatura(appccTemperatura);

      final appccProducto = AppccProducto(
        idAppccProducto: 0,
        idAppcc: idAppcc,
        estadoProductoCongelador1: producto['estado_congelador1'],
        estadoProductoCongelador2: producto['estado_congelador2'],
        estadoProductoCongelador3: producto['estado_congelador3'],
        estadoProductoCamara1: producto['estado_camara1'],
        estadoProductoCamara2: producto['estado_camara2'],
        estadoProductoMesa1: producto['estado_mesa1'],
        estadoProductoMesa2: producto['estado_mesa2'],
        estadoProductoMesa3: producto['estado_mesa3'],
        temperaturaProductoCongelador1: producto['temp_congelador1'],
        temperaturaProductoCongelador2: producto['temp_congelador2'],
        temperaturaProductoCongelador3: producto['temp_congelador3'],
        temperaturaProductoCamara1: producto['temp_camara1'],
        temperaturaProductoCamara2: producto['temp_camara2'],
        temperaturaProductoMesa1: producto['temp_mesa1'],
        temperaturaProductoMesa2: producto['temp_mesa2'],
        temperaturaProductoMesa3: producto['temp_mesa3'],
        observaciones: observacionesProducto,
      );
      await _appccService.createProducto(appccProducto);

      final appccFreidora = AppccFreidora(
        idAppccFreidora: 0,
        idAppcc: idAppcc,
        temperaturaFreidora1: freidora['temperatura_freidora1'],
        temperaturaFreidora2: freidora['temperatura_freidora2'],
        tpmFreidora1: freidora['tpm_freidora1'],
        tpmFreidora2: freidora['tpm_freidora2'],
        observaciones: observacionesFreidora,
      );
      await _appccService.createFreidora(appccFreidora);

      await loadAppccList();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAppcc(int idAppcc) async {
    try {
      await _appccService.deleteAppcc(idAppcc);
      await loadAppccList();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAppccDetalle(int idAppcc) async {
    try {
      final appcc = await _appccService.getAppcc(idAppcc);
      final limpieza = await _appccService.getLimpieza(idAppcc);
      final temperatura = await _appccService.getTemperatura(idAppcc);
      final producto = await _appccService.getProducto(idAppcc);
      final freidora = await _appccService.getFreidora(idAppcc);
      
      return {
        'appcc': appcc,
        'limpieza': limpieza,
        'temperatura': temperatura,
        'producto': producto,
        'freidora': freidora,
      };
    } catch (e) {
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateAppccCompleto({
    required int idAppcc,
    required String turno,
    required String? observacionesGenerales,
    required bool completado,
    required int idUsuario,
    required Map<String, bool?> limpieza,
    required String? observacionesLimpieza,
    required int? idLimpieza,
    required Map<String, double?> temperatura,
    required String? observacionesTemperatura,
    required int? idTemperatura,
    required Map<String, dynamic> producto,
    required String? observacionesProducto,
    required int? idProducto,
    required Map<String, double?> freidora,
    required String? observacionesFreidora,
    required int? idFreidora,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final appcc = Appcc(
        idAppcc: idAppcc,
        fecha: DateTime.now(),
        turno: turno,
        completado: completado,
        observaciones: observacionesGenerales,
        idUsuario: idUsuario,
      );
      await _appccService.updateAppcc(idAppcc, appcc);

      final appccLimpieza = AppccLimpieza(
        idAppccLimpieza: idLimpieza ?? 0,
        idAppcc: idAppcc,
        congelador1: limpieza['congelador1'],
        congelador2: limpieza['congelador2'],
        congelador3: limpieza['congelador3'],
        camara1: limpieza['camara1'],
        camara2: limpieza['camara2'],
        mesa1: limpieza['mesa1'],
        mesa2: limpieza['mesa2'],
        mesa3: limpieza['mesa3'],
        paredes: limpieza['paredes'],
        suelo: limpieza['suelo'],
        observaciones: observacionesLimpieza,
      );
      if (idLimpieza != null && idLimpieza > 0) {
        await _appccService.updateLimpieza(idLimpieza, appccLimpieza);
      } else {
        await _appccService.createLimpieza(appccLimpieza);
      }

      final appccTemperatura = AppccTemperatura(
        idAppccTemperatura: idTemperatura ?? 0,
        idAppcc: idAppcc,
        congelador1: temperatura['congelador1'],
        congelador2: temperatura['congelador2'],
        congelador3: temperatura['congelador3'],
        camara1: temperatura['camara1'],
        camara2: temperatura['camara2'],
        mesa1: temperatura['mesa1'],
        mesa2: temperatura['mesa2'],
        mesa3: temperatura['mesa3'],
        observaciones: observacionesTemperatura,
      );
      if (idTemperatura != null && idTemperatura > 0) {
        await _appccService.updateTemperatura(idTemperatura, appccTemperatura);
      } else {
        await _appccService.createTemperatura(appccTemperatura);
      }

      final appccProducto = AppccProducto(
        idAppccProducto: idProducto ?? 0,
        idAppcc: idAppcc,
        estadoProductoCongelador1: producto['estado_congelador1'],
        estadoProductoCongelador2: producto['estado_congelador2'],
        estadoProductoCongelador3: producto['estado_congelador3'],
        estadoProductoCamara1: producto['estado_camara1'],
        estadoProductoCamara2: producto['estado_camara2'],
        estadoProductoMesa1: producto['estado_mesa1'],
        estadoProductoMesa2: producto['estado_mesa2'],
        estadoProductoMesa3: producto['estado_mesa3'],
        temperaturaProductoCongelador1: producto['temp_congelador1'],
        temperaturaProductoCongelador2: producto['temp_congelador2'],
        temperaturaProductoCongelador3: producto['temp_congelador3'],
        temperaturaProductoCamara1: producto['temp_camara1'],
        temperaturaProductoCamara2: producto['temp_camara2'],
        temperaturaProductoMesa1: producto['temp_mesa1'],
        temperaturaProductoMesa2: producto['temp_mesa2'],
        temperaturaProductoMesa3: producto['temp_mesa3'],
        observaciones: observacionesProducto,
      );
      if (idProducto != null && idProducto > 0) {
        await _appccService.updateProducto(idProducto, appccProducto);
      } else {
        await _appccService.createProducto(appccProducto);
      }

      final appccFreidora = AppccFreidora(
        idAppccFreidora: idFreidora ?? 0,
        idAppcc: idAppcc,
        temperaturaFreidora1: freidora['temperatura_freidora1'],
        temperaturaFreidora2: freidora['temperatura_freidora2'],
        tpmFreidora1: freidora['tpm_freidora1'],
        tpmFreidora2: freidora['tpm_freidora2'],
        observaciones: observacionesFreidora,
      );
      if (idFreidora != null && idFreidora > 0) {
        await _appccService.updateFreidora(idFreidora, appccFreidora);
      } else {
        await _appccService.createFreidora(appccFreidora);
      }

      await loadAppccList();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
