import 'dart:convert';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

EditarUsuario(Usuario usuario) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // El backend espera este formato.
  };
  // var url = Uri.parse("http://89.117.149.126/acbmin/api/users/usuarios/" +
  //   usuario.email.toString());
  var url = Uri.parse(
      "https://acbmin.lamasoft.org/api/usuarios/" + usuario.email.toString());
  // var url = Uri.parse(
  // "http://localhost:8050/tallerautomotriz/almacen/transact/entrada");
  Map<String, dynamic> usuarioJSON = usuario.toJson();

  var response = await http.put(
    url,
    headers: headers,
    body: json.encode(usuarioJSON),
  );

  if (response.statusCode == 200) {
    //   Map<String, dynamic> jsonData = json.decode(response.body);
    // List<Map<String, dynamic>> jsonData = json.decode(response.body);
    //var jsonData = json.decode(response.body);
    return "OK";
  } else {
    //throw Exception('Error al obtener productos: ${response.statusCode}');
    return "ERROR";
  }
}
