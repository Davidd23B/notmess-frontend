import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/albaran.dart';
import '../models/linea_albaran.dart';
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class AlbaranService {
  final AuthService _authService = AuthService();

  Future<List<Albaran>> getAlbaranes() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.get(
      Uri.parse(ApiConstants.albaranes),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Albaran.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener albaranes: ${response.statusCode}');
    }
  }

  Future<Albaran> getAlbaran(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.get(
      Uri.parse('${ApiConstants.albaranes}/$id'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      return Albaran.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al obtener albarán: ${response.statusCode}');
    }
  }

  Future<List<LineaAlbaran>> getLineasAlbaran(int idAlbaran) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.get(
      Uri.parse('${ApiConstants.lineasAlbaran}/albaran/$idAlbaran'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => LineaAlbaran.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener líneas: ${response.statusCode}');
    }
  }

  Future<Albaran> createAlbaran(Albaran albaran) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.post(
      Uri.parse(ApiConstants.albaranes),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(albaran.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Albaran.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al crear albarán: ${response.statusCode}');
    }
  }

  Future<LineaAlbaran> createLineaAlbaran(LineaAlbaran linea) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.post(
      Uri.parse(ApiConstants.lineasAlbaran),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(linea.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return LineaAlbaran.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      try {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = errorBody['message'] ?? errorBody['error'] ?? 'Error al crear línea';
        throw Exception(errorMessage);
      } catch (e) {
        if (e.toString().contains('El producto ya está agregado')) {
          throw Exception('El producto ya está agregado a este albarán');
        }
        throw Exception('Error al crear línea: ${response.statusCode}');
      }
    }
  }

  Future<void> updateAlbaran(int id, Albaran albaran) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.put(
      Uri.parse('${ApiConstants.albaranes}/$id'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(albaran.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar albarán: ${response.statusCode}');
    }
  }

  Future<void> updateLineaAlbaran(int id, LineaAlbaran linea) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.put(
      Uri.parse('${ApiConstants.lineasAlbaran}/$id'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(linea.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar línea: ${response.statusCode}');
    }
  }

  Future<void> deleteAlbaran(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.delete(
      Uri.parse('${ApiConstants.albaranes}/$id'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = errorBody['message'] ?? errorBody['error'] ?? 'Error al eliminar albarán';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Error al eliminar albarán: ${response.statusCode}');
      }
    }
  }

  Future<void> deleteLineaAlbaran(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.delete(
      Uri.parse('${ApiConstants.lineasAlbaran}/$id'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar línea: ${response.statusCode}');
    }
  }

  Future<bool> validarAlbaran(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.post(
      Uri.parse('${ApiConstants.albaranes}/$id/validar'),
      headers: ApiConstants.getHeaders(token),
    );

    return response.statusCode == 200;
  }
}
