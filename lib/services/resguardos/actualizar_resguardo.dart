import 'dart:convert';
import 'package:acbmin_site/entity/Resguardo.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

Future<bool> actualizarResguardo(int folio, Resguardo resguardo) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  var url = Uri.parse("https://acbmin.lamasoft.org/api/resguardos/$folio");
  //var url = Uri.parse("http://localhost:8050/api/resguardos/$folio"); // Local

  Map<String, dynamic> resguardoJson = resguardo.toJson();

  try {
    var response = await http.put(
      // Usar PUT para actualizar
      url,
      headers: headers,
      body: json.encode(resguardoJson),
    );

    if (response.statusCode == 200) {
      return true; // Éxito
    } else {
      print('Error actualizarResguardo: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false; // Error
    }
  } catch (e) {
    print('Error en la solicitud actualizarResguardo: $e');
    return false;
  }
}
