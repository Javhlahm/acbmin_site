import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Esta es la llave con la que guardaremos el token.
  final _tokenKey = 'auth_token';

  // Variable para guardar el token en la memoria de la app y no leerlo del disco cada vez.
  String? _token;

  // Método para GUARDAR el token en el almacenamiento.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _token = token; // También lo guardamos en memoria.
  }

  // Método para LEER el token del almacenamiento.
  Future<String?> getToken() async {
    // Si ya lo tenemos en memoria, lo devolvemos para ser más rápidos.
    if (_token != null) return _token;

    // Si no, lo leemos del disco (o localStorage en web).
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }

  // Método para BORRAR el token (al cerrar sesión).
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _token = null; // Limpiamos también la variable de memoria.
  }
}

// Creamos una instancia global para que sea fácil de usar en toda la app.
final authService = AuthService();
