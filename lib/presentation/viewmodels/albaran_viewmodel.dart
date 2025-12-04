import 'package:flutter/material.dart';
import '../../data/models/albaran.dart';
import '../../data/models/linea_albaran.dart';
import '../../data/services/albaran_service.dart';

class AlbaranViewModel extends ChangeNotifier {
  final AlbaranService _albaranService = AlbaranService();

  List<Albaran> _albaranesCompletos = [];
  List<Albaran> _albaranes = [];
  List<LineaAlbaran> _lineasActuales = [];
  bool _isLoading = false;
  String? _tipoFiltro;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  List<Albaran> get albaranes => _albaranes;
  List<LineaAlbaran> get lineasActuales => _lineasActuales;
  bool get isLoading => _isLoading;
  String? get tipoFiltro => _tipoFiltro;
  DateTime? get fechaDesde => _fechaDesde;
  DateTime? get fechaHasta => _fechaHasta;

  Future<void> loadAlbaranes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _albaranesCompletos = await _albaranService.getAlbaranes();
      _aplicarFiltros();
    } catch (e) {
      // No hacer nada.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _aplicarFiltros() {
    List<Albaran> listaFiltrada = List.from(_albaranesCompletos);

    if (_tipoFiltro != null && _tipoFiltro!.isNotEmpty) {
      listaFiltrada = listaFiltrada
          .where((a) => a.tipo.toLowerCase() == _tipoFiltro!.toLowerCase())
          .toList();
    }
    if (_fechaDesde != null) {
      final fechaDesdeSinHora = DateTime(_fechaDesde!.year, _fechaDesde!.month, _fechaDesde!.day);
      listaFiltrada = listaFiltrada
          .where((a) {
            final fechaAlbaran = DateTime(a.fechaHora.year, a.fechaHora.month, a.fechaHora.day);
            return !fechaAlbaran.isBefore(fechaDesdeSinHora);
          })
          .toList();
    }

    if (_fechaHasta != null) {
      final fechaHastaSinHora = DateTime(_fechaHasta!.year, _fechaHasta!.month, _fechaHasta!.day, 23, 59, 59);
      listaFiltrada = listaFiltrada
          .where((a) => !a.fechaHora.isAfter(fechaHastaSinHora))
          .toList();
    }

    listaFiltrada.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    
    _albaranes = listaFiltrada;
  }

  Future<Albaran?> getAlbaran(int id) async {
    try {
      return await _albaranService.getAlbaran(id);
    } catch (e) {
      notifyListeners();
      return null;
    }
  }

  Future<void> loadLineasAlbaran(int idAlbaran) async {
    _isLoading = true;
    notifyListeners();

    try {
      _lineasActuales = await _albaranService.getLineasAlbaran(idAlbaran);
    } catch (e) {
      // No hacer nada.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Albaran?> createAlbaranWithLineas({
    required String tipo,
    String? motivoMerma,
    required List<LineaAlbaran> lineas,
    required int idUsuario,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final nuevoAlbaran = Albaran(
        idAlbaran: 0,
        fechaHora: DateTime.now(),
        tipo: tipo,
        motivoMerma: motivoMerma,
        idUsuario: idUsuario,
      );
      
      final albaranCreado = await _albaranService.createAlbaran(nuevoAlbaran);
      
      for (final linea in lineas) {
        final lineaConAlbaran = LineaAlbaran(
          idLineaAlbaran: 0,
          idAlbaran: albaranCreado.idAlbaran,
          idProducto: linea.idProducto,
          cantidad: linea.cantidad,
          nombreProducto: linea.nombreProducto,
        );
        await _albaranService.createLineaAlbaran(lineaConAlbaran);
      }
      
      await loadAlbaranes();
      return albaranCreado;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateAlbaran(int id, Albaran albaran) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _albaranService.updateAlbaran(id, albaran);
      await loadAlbaranes();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAlbaran(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _albaranService.deleteAlbaran(id);
      await loadAlbaranes();
    } catch (e) {
      // No hacer nada.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLineaAlbaran(int id, int idAlbaran) async {
    try {
      await _albaranService.deleteLineaAlbaran(id);
      await loadLineasAlbaran(idAlbaran);
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  void setTipoFiltro(String? tipo) {
    _tipoFiltro = tipo;
    _aplicarFiltros();
    notifyListeners();
  }

  void setFechaDesde(DateTime? fecha) {
    _fechaDesde = fecha;
    _aplicarFiltros();
    notifyListeners();
  }

  void setFechaHasta(DateTime? fecha) {
    _fechaHasta = fecha;
    _aplicarFiltros();
    notifyListeners();
  }

  void clearFiltrosFecha() {
    _fechaDesde = null;
    _fechaHasta = null;
    _aplicarFiltros();
    notifyListeners();
  }

  void limpiarFiltros() {
    _tipoFiltro = null;
    _fechaDesde = null;
    _fechaHasta = null;
    _aplicarFiltros();
    notifyListeners();
  }
}
