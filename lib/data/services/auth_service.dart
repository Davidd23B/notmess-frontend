import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRolKey = 'user_rol';
  Future<LoginResponse> login(String nombre, String passwd) async {
    final url = Uri.parse(ApiConstants.login);
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'nombre': nombre,
        'passwd': passwd,
      }),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      await _saveCredentials(loginResponse);
      return loginResponse;
    } else {
      throw Exception('Error de autenticación: ${response.body}');
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        final url = Uri.parse(ApiConstants.logout);
        await http.post(
          url,
          headers: ApiConstants.getHeaders(token),
        );
      } catch (e) {
        //No hacer nada.
      }
    }
    await _clearCredentials();
  }

  Future<bool> verifyToken() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final url = Uri.parse(ApiConstants.verifyToken);
      final response = await http.get(
        url,
        headers: ApiConstants.getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;

    return {
      'token': token,
      'id_usuario': prefs.getInt(_userIdKey),
      'nombre': prefs.getString(_userNameKey),
      'rol': prefs.getString(_userRolKey),
    };
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    return await verifyToken();
  }

  Future<void> _saveCredentials(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, response.token);
    await prefs.setInt(_userIdKey, response.idUsuario);
    await prefs.setString(_userNameKey, response.nombre);
    await prefs.setString(_userRolKey, response.rol);
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRolKey);
  }
}
