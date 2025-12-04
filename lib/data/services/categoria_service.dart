import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_producto.dart';
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class CategoriaService {
  final AuthService _authService = AuthService();

  Future<List<CategoriaProducto>> getCategorias() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception();

    final response = await http.get(
      Uri.parse(ApiConstants.categorias),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => CategoriaProducto.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  Future<CategoriaProducto> getCategoria(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception();

    final response = await http.get(
      Uri.parse('${ApiConstants.categorias}/$id'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      return CategoriaProducto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception();
    }
  }

  Future<CategoriaProducto> createCategoria(CategoriaProducto categoria) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception();

    final response = await http.post(
      Uri.parse(ApiConstants.categorias),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(categoria.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return CategoriaProducto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception();
    }
  }

  Future<void> updateCategoria(int id, CategoriaProducto categoria) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception();

    final response = await http.put(
      Uri.parse('${ApiConstants.categorias}/$id'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(categoria.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception();
    }
  }

  Future<void> deleteCategoria(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception();

    final response = await http.delete(
      Uri.parse('${ApiConstants.categorias}/$id'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception();
    }
  }
}
