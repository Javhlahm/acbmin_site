import 'dart:convert';
import 'package:acbmin_site/entity/BajaBien.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

Future<BajaBien?> crearBaja(BajaBien baja) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  //var url = Uri.parse("https://acbmin.lamasoft.org/api/bajas");
  var url = Uri.parse("http://localhost:8050/api/bajas"); // Local

  // Asegúrate que tu clase BajaBien tenga el método toJson()
  Map<String, dynamic> bajaJson = baja.toJson();

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(bajaJson),
    );

    if (response.statusCode == 201) {
      // 201 Created
      Map<String, dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));
      return BajaBien.fromJson(
          jsonData); // Devuelve la baja creada con su folio
    } else {
      print('Error crearBaja: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error en la solicitud crearBaja: $e');
    return null;
  }
}
