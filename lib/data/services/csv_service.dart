import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class CsvResponse {
  final List<int> bytes;
  final String nombreArchivo;

  CsvResponse({required this.bytes, required this.nombreArchivo});
}

class CsvService {
  final AuthService _authService = AuthService();

  String _extraerNombreArchivo(http.Response response) {
    final contentDisposition = response.headers['content-disposition'];
    if (contentDisposition != null) {
      final regex = RegExp(r'filename="(.+)"');
      final match = regex.firstMatch(contentDisposition);
      if (match != null) {
        return match.group(1)!;
      }
    }
    return 'productos_${DateTime.now().millisecondsSinceEpoch}.csv';
  }

  Future<CsvResponse> exportarTodosLosProductos() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.get(
      Uri.parse('${ApiConstants.productos}/exportarCsv'),
      headers: ApiConstants.getHeaders(token),
    );

    if (response.statusCode == 200) {
      return CsvResponse(
        bytes: response.bodyBytes,
        nombreArchivo: _extraerNombreArchivo(response),
      );
    } else {
      throw Exception('Error al exportar productos: ${response.statusCode}');
    }
  }

  Future<CsvResponse> exportarProductosSeleccionados(List<int> productosIds) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.post(
      Uri.parse('${ApiConstants.productos}/exportarCsv/custom'),
      headers: ApiConstants.getHeaders(token),
      body: json.encode(productosIds),
    );

    if (response.statusCode == 200) {
      return CsvResponse(
        bytes: response.bodyBytes,
        nombreArchivo: _extraerNombreArchivo(response),
      );
    } else {
      throw Exception('Error al exportar productos seleccionados: ${response.statusCode}');
    }
  }
}
