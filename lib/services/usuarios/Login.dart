import 'package:acbmin_site/config/api_config.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Login(String correo, String contrasena) async {
  var url = ApiConfig.endpoint("usuarios/login");
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
  if (response.statusCode == 200) {
    return response.body;
  } else if (response.statusCode == 429) {
    // nginx limita los intentos de inicio de sesión por minuto.
    throw const ApiException(
        'Demasiados intentos. Espera un minuto e intenta de nuevo.',
        statusCode: 429);
  } else {
    //throw Exception('Error al obtener productos: ${response.statusCode}');
    return null;
  }
}
