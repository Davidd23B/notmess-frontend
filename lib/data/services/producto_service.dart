import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/producto.dart';
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class ProductoService {
  final AuthService _authService = AuthService();

  Future<List<Producto>> getProductos() async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.productos}?t=${DateTime.now().millisecondsSinceEpoch}');
    
    final response = await http.get(
      url,
      headers: ApiConstants.getHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  Future<Producto> getProducto(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.productos}/$id');
    
    final response = await http.get(
      url,
      headers: ApiConstants.getHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception();
    }
  }

  Future<Producto> createProducto(Producto producto) async {
    final token = await _authService.getToken();
    final url = Uri.parse(ApiConstants.productos);
    
    final response = await http.post(
      url,
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception();
    }
  }

  Future<Producto> updateProducto(int id, Producto producto) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.productos}/$id');
    
    final response = await http.put(
      url,
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception();
    }
  }

  Future<void> deleteProducto(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.productos}/$id');
    
    final response = await http.delete(
      url,
      headers: ApiConstants.getHeaders(token ?? ''),
    );
    
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception();
    }
  }

  Future<List<Producto>> getProductosPorCategoria(int categoriaId) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.productos}/categoria/$categoriaId');
    
    final response = await http.get(
      url,
      headers: ApiConstants.getHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  Future<Producto> uploadImagen(int id, File imageFile) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.productos}/$id/imagen');
    
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    
    final mimeType = lookupMimeType(imageFile.path);
    final mimeTypeSplit = mimeType?.split('/') ?? ['application', 'octet-stream'];
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1]),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final errorBody = response.body;
      if (response.statusCode == 500) {
        throw Exception('Error del servidor al subir imagen.');
      } else if (response.statusCode == 413) {
        throw Exception('Imagen demasiado grande. Máximo 2MB');
      } else if (response.statusCode == 415) {
        throw Exception('Tipo de imagen no permitido. Usa JPG, PNG o WEBP');
      }
      throw Exception('Error al subir imagen (${response.statusCode}): $errorBody');
    }
  }

  Future<void> deleteImagen(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConstants.productos}/$id/imagen');
    
    final response = await http.delete(
      url,
      headers: ApiConstants.getHeaders(token ?? ''),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception();
    }
  }
}
