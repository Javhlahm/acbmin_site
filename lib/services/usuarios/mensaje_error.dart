import 'dart:convert';

import 'package:http/http.dart' as http;

/// Contraseña mínima, igual que en la API.
const int largoMinimoContrasena = 8;

/// Texto para mostrar cuando la API rechaza crear o actualizar un usuario.
/// Micronaut manda el motivo en _embedded.errors[0].message.
String mensajeDeErrorUsuario(http.Response respuesta, String accion) {
  if (respuesta.statusCode == 400) {
    try {
      final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
      final errores = (cuerpo['_embedded'] as Map?)?['errors'];
      if (errores is List && errores.isNotEmpty) {
        return (errores.first as Map)['message'].toString();
      }
    } catch (_) {}
    return 'Revisa los datos capturados.';
  }
  if (respuesta.statusCode == 401) return 'Tu sesión expiró. Inicia sesión nuevamente.';
  if (respuesta.statusCode == 403) return 'No tienes permiso para administrar usuarios.';
  return 'No fue posible $accion el usuario (${respuesta.statusCode}).';
}

/// Validador de una contraseña nueva; [obligatoria] es false al editar.
String? validarContrasena(String? valor, {required bool obligatoria}) {
  final texto = valor ?? '';
  if (texto.isEmpty) return obligatoria ? 'Campo requerido' : null;
  if (texto.length < largoMinimoContrasena) {
    return 'Debe tener al menos $largoMinimoContrasena caracteres';
  }
  return null;
}
