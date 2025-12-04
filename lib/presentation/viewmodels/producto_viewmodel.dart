import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/producto.dart';
import '../../data/models/categoria_producto.dart';
import '../../data/services/producto_service.dart';

class ProductoViewModel extends ChangeNotifier {
  final ProductoService _productoService = ProductoService();

  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  final List<CategoriaProducto> _categorias = [];
  bool _isLoading = false;
  int? _categoriaSeleccionada;
  String _searchQuery = '';

  List<Producto> get productos => _productosFiltrados;
  List<CategoriaProducto> get categorias => _categorias;
  bool get isLoading => _isLoading;
  int? get categoriaSeleccionada => _categoriaSeleccionada;
  String get searchQuery => _searchQuery;

  Future<void> loadProductos() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_categoriaSeleccionada != null) {
        _productos = await _productoService.getProductosPorCategoria(_categoriaSeleccionada!);
      } else {
        _productos = await _productoService.getProductos();
      }
      _aplicarFiltros();
    } catch (e) {
      // No hacer nada.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Producto?> getProducto(int id) async {
    try {
      return await _productoService.getProducto(id);
    } catch (e) {
      notifyListeners();
      return null;
    }
  }

  Future<Producto?> createProducto(Producto producto) async {
    _isLoading = true;
    notifyListeners();

    try {
      final productoCreado = await _productoService.createProducto(producto);
      await loadProductos();
      _isLoading = false;
      notifyListeners();
      return productoCreado;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProducto(int id, Producto producto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productoService.updateProducto(id, producto);
      await loadProductos();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProducto(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productoService.deleteProducto(id);
      await loadProductos();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadImagen(int id, File imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productoService.uploadImagen(id, imageFile);
      await loadProductos();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteImagen(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productoService.deleteImagen(id);
      await loadProductos();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setCategoria(int? categoriaId) {
    _categoriaSeleccionada = categoriaId;
    loadProductos();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _productosFiltrados = _productos.where((producto) {
      final matchesSearch = _searchQuery.isEmpty ||
          producto.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
    _productosFiltrados.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
  }

  void limpiarFiltros() {
    _categoriaSeleccionada = null;
    _searchQuery = '';
    _aplicarFiltros();
    notifyListeners();
  }
}
