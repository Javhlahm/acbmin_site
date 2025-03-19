import 'dart:convert';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:http/http.dart' as http;

NuevoUsuario(Usuario usuario) async {
  var url = Uri.parse("http://89.117.149.126/acbmin/api/users/usuarios");
  // var url = Uri.parse(
  // "http://localhost:8050/tallerautomotriz/almacen/transact/entrada");
  Map<String, dynamic> usuarioJSON = usuario.toJson();

  var response = await http.post(
    url,
    headers: {
      'Content-Type':
          'application/json', // Especificamos que estamos enviando JSON
    },
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
