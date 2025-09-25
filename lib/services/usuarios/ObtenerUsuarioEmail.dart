import 'dart:convert';

import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

Future<Usuario> obtenerUsuarioEmail(String email) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // El backend espera este formato.
  };
  //var url =
  //   Uri.parse("http://89.117.149.126/acbmin/api/users/usuarios/" + email);
  var url = Uri.parse(
      "https://acbmin.lamasoft.org/api/autoalmacen/usuarios/" + email);
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");

  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    dynamic jsonData = json.decode(response.body);
    Usuario usuario = Usuario.fromJson(jsonData);

    usuario.nombre = usuario.nombre ?? "-";
    usuario.id = usuario.id ?? 0;
    usuario.contrasena = usuario.contrasena ?? "-";
    usuario.email = usuario.email ?? "-";
    usuario.roles = usuario.roles ?? [];
    usuario.status = usuario.status ?? "-";
    return usuario;
  } else {
    throw Exception('Error al obtener Usuarios: ${response.statusCode}');
  }
}
