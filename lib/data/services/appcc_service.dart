import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appcc.dart';
import '../models/appcc_limpieza.dart';
import '../models/appcc_temperatura.dart';
import '../models/appcc_producto.dart';
import '../models/appcc_freidora.dart';
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class AppccService {
  final AuthService _authService = AuthService();

  // ========== APPCC Principal ==========
  
  Future<List<Appcc>> getAppccList() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.appcc),
      headers: ApiConstants.getHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Appcc.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar APPCC');
    }
  }

  Future<Appcc> getAppcc(int id) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.appcc}/$id'),
      headers: ApiConstants.getHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      return Appcc.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al cargar APPCC');
    }
  }

  Future<Appcc> createAppcc(Appcc appcc) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.appcc),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(appcc.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Appcc.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al crear APPCC');
    }
  }

  Future<Appcc> updateAppcc(int id, Appcc appcc) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.appcc}/$id'),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(appcc.toJson()),
    );

    if (response.statusCode == 200) {
      return Appcc.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al actualizar APPCC');
    }
  }

  Future<void> deleteAppcc(int id) async {
    final token = await _authService.getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.appcc}/$id'),
      headers: ApiConstants.getHeaders(token ?? ''),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar APPCC');
    }
  }

  // ========== APPCC Limpieza ==========

  Future<AppccLimpieza?> getLimpieza(int idAppcc) async {
    final token = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.appccLimpieza}/appcc/$idAppcc'),
        headers: ApiConstants.getHeaders(token ?? ''),
      );

      if (response.statusCode == 200) {
        return AppccLimpieza.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AppccLimpieza> createLimpieza(AppccLimpieza limpieza) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.appccLimpieza),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(limpieza.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppccLimpieza.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al crear limpieza');
    }
  }

  Future<AppccLimpieza> updateLimpieza(int id, AppccLimpieza limpieza) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.appccLimpieza}/$id'),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(limpieza.toJson()),
    );

    if (response.statusCode == 200) {
      return AppccLimpieza.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al actualizar limpieza');
    }
  }

  // ========== APPCC Temperatura ==========

  Future<AppccTemperatura?> getTemperatura(int idAppcc) async {
    final token = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.appccTemperatura}/appcc/$idAppcc'),
        headers: ApiConstants.getHeaders(token ?? ''),
      );

      if (response.statusCode == 200) {
        return AppccTemperatura.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AppccTemperatura> createTemperatura(AppccTemperatura temperatura) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.appccTemperatura),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(temperatura.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppccTemperatura.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al crear temperatura');
    }
  }

  Future<AppccTemperatura> updateTemperatura(int id, AppccTemperatura temperatura) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.appccTemperatura}/$id'),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(temperatura.toJson()),
    );

    if (response.statusCode == 200) {
      return AppccTemperatura.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al actualizar temperatura');
    }
  }

  // ========== APPCC Producto ==========

  Future<AppccProducto?> getProducto(int idAppcc) async {
    final token = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.appccProducto}/appcc/$idAppcc'),
        headers: ApiConstants.getHeaders(token ?? ''),
      );

      if (response.statusCode == 200) {
        return AppccProducto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AppccProducto> createProducto(AppccProducto producto) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.appccProducto),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppccProducto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al crear producto');
    }
  }

  Future<AppccProducto> updateProducto(int id, AppccProducto producto) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.appccProducto}/$id'),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode == 200) {
      return AppccProducto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al actualizar producto');
    }
  }

  // ========== APPCC Freidora ==========

  Future<AppccFreidora?> getFreidora(int idAppcc) async {
    final token = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.appccFreidora}/appcc/$idAppcc'),
        headers: ApiConstants.getHeaders(token ?? ''),
      );

      if (response.statusCode == 200) {
        return AppccFreidora.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AppccFreidora> createFreidora(AppccFreidora freidora) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.appccFreidora),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(freidora.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppccFreidora.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al crear freidora');
    }
  }

  Future<AppccFreidora> updateFreidora(int id, AppccFreidora freidora) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.appccFreidora}/$id'),
      headers: ApiConstants.getHeaders(token ?? ''),
      body: jsonEncode(freidora.toJson()),
    );

    if (response.statusCode == 200) {
      return AppccFreidora.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al actualizar freidora');
    }
  }
}
