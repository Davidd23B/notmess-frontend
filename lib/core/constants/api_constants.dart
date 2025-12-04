class ApiConstants {
  
  // Para Emulador Android:
  // static const String baseUrl = 'http://10.0.2.2:8080';

  // Para producción:
  static const String baseUrl = 'http://davidb.es:8080';
  
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String verifyToken = '$baseUrl/auth/verify-token';
  
  static const String productos = '$baseUrl/api/productos';
  
  static const String categorias = '$baseUrl/api/categorias';
  
  static const String albaranes = '$baseUrl/api/albaranes';
  static const String lineasAlbaran = '$baseUrl/api/lineas-albaran';
  
  static const String appcc = '$baseUrl/api/appcc';
  static const String appccLimpieza = '$baseUrl/api/appcc/limpieza';
  static const String appccTemperatura = '$baseUrl/api/appcc/temperatura';
  static const String appccProducto = '$baseUrl/api/appcc/producto';
  static const String appccFreidora = '$baseUrl/api/appcc/freidora';
  
  static const String usuarios = '$baseUrl/api/usuarios';
  
  static Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }
}
