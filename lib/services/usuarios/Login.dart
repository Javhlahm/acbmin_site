import 'dart:convert';
import 'package:http/http.dart' as http;

Login(String correo, String contrasena) async {
  var url = Uri.parse("http://89.117.149.126/acbmin/api/users/usuarios/login");
  // var url = Uri.parse(
  // "http://localhost:8050/tallerautomotriz/almacen/transact/entrada");
  Map<String, dynamic> usuarioJSON = new Map();
  usuarioJSON['email'] = correo;
  usuarioJSON['contrasena'] = contrasena;

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
