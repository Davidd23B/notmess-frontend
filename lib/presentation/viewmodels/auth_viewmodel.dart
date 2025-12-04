import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/usuario.dart';
import '../../data/models/login_response.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Usuario? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _userError;
  String? _passwordError;

  Usuario? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get userError => _userError;
  String? get passwordError => _passwordError;
  bool get isAuthenticated => _currentUser != null && _token != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> initialize() async {
    try {
      final savedData = await _authService.getSavedUserData();
      if (savedData != null) {
        final isValid = await _authService.verifyToken();
        if (isValid) {
          _token = savedData['token'];
          _currentUser = Usuario(
            idUsuario: savedData['id_usuario'],
            nombre: savedData['nombre'],
            rol: savedData['rol'],
            activo: true,
          );
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String nombre, String passwd) async {
    _isLoading = true;
    _userError = null;
    _passwordError = null;
    notifyListeners();

    try {
      final LoginResponse response = await _authService.login(nombre, passwd);
      _token = response.token;
      _currentUser = response.toUsuario();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _userError = 'Usuario incorrecto';
      _passwordError = 'Contraseña incorrecta';
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  void clearError() {
    _userError = null;
    _passwordError = null;
    notifyListeners();
  }

  void clearUserError() {
    _userError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    _passwordError = null;
    notifyListeners();
  }
}
