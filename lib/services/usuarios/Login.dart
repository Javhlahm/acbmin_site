import 'dart:convert';
import 'package:http/http.dart' as http;

Login(String correo, String contrasena) async {
  // var url = Uri.parse("http://89.117.149.126/acbmin/api/users/usuarios/login");
  var url =
      Uri.parse("https://acbmin.lamasoft.org/api/autoalmacen/usuarios/login");
  //var url = Uri.parse("http://localhost:8050/usuarios/login");
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
  print(response.body);
  if (response.statusCode == 200) {
    return response.body;
  } else {
    //throw Exception('Error al obtener productos: ${response.statusCode}');
    return null;
  }
}
