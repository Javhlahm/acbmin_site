import 'dart:convert';
import 'package:acbmin_site/entity/BajaBien.dart'; // Asegúrate que la ruta sea correcta
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

// Función para obtener TODAS las bajas
Future<List<BajaBien>> obtenerBajas() async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  // URL base + endpoint de bajas
  var url = Uri.parse("https://acbmin.lamasoft.org/api/bajas");
  //var url = Uri.parse("http://localhost:8050/api/bajas"); // Local

  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
    List<BajaBien> bajas =
        jsonData.map((json) => BajaBien.fromJson(json)).toList();
    // Añadir validación de nulos si es necesario, similar a Resguardo.fromJson
    return bajas;
  } else {
    print('Error obtenerBajas: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Error al obtener Bajas: ${response.statusCode}');
  }
}

// Función para obtener UNA baja por folio
Future<BajaBien> obtenerBajaPorFolio(int folio) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  var url = Uri.parse("https://acbmin.lamasoft.org/api/bajas/$folio");
  //var url = Uri.parse("http://localhost:8050/api/bajas/$folio"); // Local

  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData =
        json.decode(utf8.decode(response.bodyBytes));
    return BajaBien.fromJson(jsonData);
  } else {
    print('Error obtenerBajaPorFolio: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Error al obtener la Baja $folio: ${response.statusCode}');
  }
}
