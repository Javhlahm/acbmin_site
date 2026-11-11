import 'dart:convert';

import 'package:acbmin_site/config/api_config.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:acbmin_site/services/usuarios/mensaje_error.dart';
import 'package:http/http.dart' as http;

/// Cambia la contraseña del usuario que tiene la sesión abierta.
/// Regresa null si se cambió, o el mensaje de error para mostrar.
Future<String?> cambiarMiContrasena(String actual, String nueva) async {
  final token = await authService.getToken();
  final respuesta = await http.put(
    ApiConfig.endpoint('usuarios/mi-contrasena'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({'contrasenaActual': actual, 'contrasenaNueva': nueva}),
  );

  if (respuesta.statusCode == 200) {
    // Las demás sesiones se cerraron; la API manda un token nuevo para esta.
    await authService.saveToken(respuesta.body);
    return null;
  }
  if (respuesta.statusCode == 429) {
    return 'Demasiados intentos. Espera un minuto e intenta de nuevo.';
  }
  return mensajeDeErrorUsuario(respuesta, 'cambiar la contraseña de');
}
