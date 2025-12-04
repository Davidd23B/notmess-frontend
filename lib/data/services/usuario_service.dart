import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class UsuarioService {
  final AuthService _authService = AuthService();

  Future<List<Usuario>> getUsuarios() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.get(
      Uri.parse(ApiConstants.usuarios),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener usuarios: ${response.statusCode}');
    }
  }

  Future<Usuario> getUsuario(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.get(
      Uri.parse('${ApiConstants.usuarios}/$id'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al obtener usuario: ${response.statusCode}');
    }
  }

  Future<Usuario> createUsuario(Usuario usuario) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.post(
      Uri.parse(ApiConstants.usuarios),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Usuario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al crear usuario: ${response.statusCode}');
    }
  }

  Future<void> updateUsuario(int id, Usuario usuario) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.put(
      Uri.parse('${ApiConstants.usuarios}/$id'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario: ${response.statusCode}');
    }
  }

  Future<void> deleteUsuario(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.delete(
      Uri.parse('${ApiConstants.usuarios}/$id'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar usuario: ${response.statusCode}');
    }
  }

  Future<void> activateUsuario(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.put(
      Uri.parse('${ApiConstants.usuarios}/$id/activar'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al activar usuario: ${response.statusCode}');
    }
  }
}
