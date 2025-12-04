import 'package:flutter/material.dart';
import '../../data/models/categoria_producto.dart';
import '../../data/services/categoria_service.dart';

class CategoriaViewModel extends ChangeNotifier {
  final CategoriaService _categoriaService = CategoriaService();

  List<CategoriaProducto> _categorias = [];
  bool _isLoading = false;

  List<CategoriaProducto> get categorias => _categorias;
  bool get isLoading => _isLoading;

  Future<void> loadCategorias() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categorias = await _categoriaService.getCategorias();
      _categorias.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CategoriaProducto?> getCategoria(int id) async {
    try {
      return await _categoriaService.getCategoria(id);
    } catch (e) {
      notifyListeners();
      return null;
    }
  }

  Future<bool> createCategoria(CategoriaProducto categoria) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _categoriaService.createCategoria(categoria);
      await loadCategorias();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategoria(int id, CategoriaProducto categoria) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _categoriaService.updateCategoria(id, categoria);
      await loadCategorias();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _categoriaService.deleteCategoria(id);
      await loadCategorias();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void limpiarFiltros() {
  }
}
