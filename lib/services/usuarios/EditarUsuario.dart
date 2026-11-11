import 'package:acbmin_site/config/api_config.dart';
import 'dart:convert';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:acbmin_site/services/usuarios/mensaje_error.dart';
import 'package:http/http.dart' as http;

EditarUsuario(Usuario usuario) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // El backend espera este formato.
  };
  var url = ApiConfig.endpoint("usuarios/" + usuario.email.toString());
  // var url = Uri.parse(
  // "http://localhost:8050/tallerautomotriz/almacen/transact/entrada");
  Map<String, dynamic> usuarioJSON = usuario.toJson();

  var response = await http.put(
    url,
    headers: headers,
    body: json.encode(usuarioJSON),
  );

  if (response.statusCode == 200) {
    return "OK";
  }
  // Si la API rechaza los datos (contraseña corta, correo repetido...) explica por qué.
  return mensajeDeErrorUsuario(response, 'actualizar');
}
