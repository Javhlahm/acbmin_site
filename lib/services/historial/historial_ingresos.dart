import 'dart:convert';

import 'package:acbmin_site/config/api_config.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

/// Un renglón del historial de ingresos (las horas vienen en hora de México).
class IngresoUsuario {
  IngresoUsuario({
    required this.email,
    this.nombre,
    required this.exitoso,
    this.ip,
    this.navegador,
    required this.fechaEntrada,
    this.fechaSalida,
    this.ultimoUso,
  });

  final String email;
  final String? nombre;
  final bool exitoso;
  final String? ip;
  final String? navegador;
  final DateTime fechaEntrada;
  final DateTime? fechaSalida;
  final DateTime? ultimoUso;

  factory IngresoUsuario.fromJson(Map<String, dynamic> json) {
    DateTime? fecha(dynamic valor) =>
        valor == null ? null : DateTime.tryParse(valor.toString());
    return IngresoUsuario(
      email: json['email']?.toString() ?? '',
      nombre: json['nombre']?.toString(),
      exitoso: json['exitoso'] == true,
      ip: json['ip']?.toString(),
      navegador: json['navegador']?.toString(),
      fechaEntrada: fecha(json['fechaEntrada']) ?? DateTime(1970),
      fechaSalida: fecha(json['fechaSalida']),
      ultimoUso: fecha(json['ultimoUso']),
    );
  }

  /// Texto de búsqueda: nombre, correo e IP.
  bool coincide(String texto) {
    final buscado = texto.trim().toLowerCase();
    if (buscado.isEmpty) return true;
    return email.toLowerCase().contains(buscado) ||
        (nombre ?? '').toLowerCase().contains(buscado) ||
        (ip ?? '').contains(buscado);
  }

  /// Navegador y sistema en pocas palabras, p. ej. "Chrome en Windows".
  String get navegadorCorto {
    final ua = navegador ?? '';
    if (ua.isEmpty) return '-';
    final String nav;
    if (ua.contains('Edg/')) {
      nav = 'Edge';
    } else if (ua.contains('OPR/')) {
      nav = 'Opera';
    } else if (ua.contains('Firefox/')) {
      nav = 'Firefox';
    } else if (ua.contains('Chrome/') || ua.contains('CriOS/')) {
      nav = 'Chrome';
    } else if (ua.contains('Safari/')) {
      nav = 'Safari';
    } else {
      nav = 'Otro navegador';
    }
    final String sistema;
    if (ua.contains('Android')) {
      sistema = 'Android';
    } else if (ua.contains('iPhone') || ua.contains('iPad')) {
      sistema = 'iPhone/iPad';
    } else if (ua.contains('Windows')) {
      sistema = 'Windows';
    } else if (ua.contains('Mac OS')) {
      sistema = 'Mac';
    } else if (ua.contains('Linux')) {
      sistema = 'Linux';
    } else {
      return nav;
    }
    return '$nav en $sistema';
  }
}

Map<String, String> _encabezados(String? token) => {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

/// Historial de los últimos [dias] días (solo admin).
Future<List<IngresoUsuario>> obtenerHistorialIngresos(int dias) async {
  final token = await authService.getToken();
  final respuesta = await http.get(
      ApiConfig.endpoint('historial-ingresos?dias=$dias'),
      headers: _encabezados(token));
  if (respuesta.statusCode != 200) {
    throw Exception(respuesta.statusCode == 403
        ? 'Solo un administrador puede ver el historial.'
        : 'No fue posible cargar el historial (${respuesta.statusCode}).');
  }
  final datos = json.decode(utf8.decode(respuesta.bodyBytes)) as List;
  return datos
      .map((e) => IngresoUsuario.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Avisa a la API que el usuario cerró sesión, para guardar la hora de salida.
/// Si falla (sin red, sesión vencida) no importa: se cierra la sesión igual.
Future<void> avisarSalida() async {
  try {
    final token = await authService.getToken();
    if (token == null) return;
    await http
        .post(ApiConfig.endpoint('usuarios/salir'),
            headers: _encabezados(token))
        .timeout(const Duration(seconds: 3));
  } catch (_) {}
}
