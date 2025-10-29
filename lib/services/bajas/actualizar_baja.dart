import 'dart:convert';
import 'package:acbmin_site/entity/BajaBien.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

Future<bool> actualizarBaja(int folio, BajaBien baja) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  // var url =
  //   Uri.parse("https://acbmin.lamasoft.org/api/bajas/$folio");
  var url = Uri.parse("http://localhost:8050/api/bajas/$folio"); // Local

  Map<String, dynamic> bajaJson = baja.toJson();

  try {
    var response = await http.put(
      // Usar PUT
      url,
      headers: headers,
      body: json.encode(bajaJson),
    );

    if (response.statusCode == 200) {
      return true; // Éxito
    } else {
      print('Error actualizarBaja: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false; // Error
    }
  } catch (e) {
    print('Error en la solicitud actualizarBaja: $e');
    return false;
  }
}
