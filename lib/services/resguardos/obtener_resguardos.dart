import 'dart:convert';
import 'package:acbmin_site/entity/Resguardo.dart'; // Asegúrate que la ruta sea correcta
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

// Función para obtener TODOS los resguardos
Future<List<Resguardo>> obtenerResguardos() async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  // URL base de tu API + endpoint de resguardos
  var url = Uri.parse("https://acbmin.lamasoft.org/api/resguardos");
  //var url = Uri.parse(
  //   "http://localhost:8050/api/resguardos"); // Para pruebas locales si aplica

  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    List<dynamic> jsonData =
        json.decode(utf8.decode(response.bodyBytes)); // Decodificar como UTF-8
    List<Resguardo> resguardos =
        jsonData.map((json) => Resguardo.fromJson(json)).toList();

    // Puedes agregar validación de nulos aquí si es necesario, similar a como lo haces en otros servicios
    // Ejemplo:
    // for (var resguardo in resguardos) {
    //   resguardo.descripcion = resguardo.descripcion ?? "-";
    //   // ... etc para otros campos ...
    // }

    return resguardos;
  } else {
    print('Error obtenerResguardos: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Error al obtener Resguardos: ${response.statusCode}');
  }
}

// Función para obtener UN resguardo por folio
Future<Resguardo> obtenerResguardoPorFolio(int folio) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  var url = Uri.parse("https://acbmin.lamasoft.org/api/resguardos/$folio");
  //var url = Uri.parse("http://localhost:8050/api/resguardos/$folio"); // Local

  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData =
        json.decode(utf8.decode(response.bodyBytes));
    return Resguardo.fromJson(jsonData);
  } else {
    print('Error obtenerResguardoPorFolio: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception(
        'Error al obtener el Resguardo $folio: ${response.statusCode}');
  }
}
