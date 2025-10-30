import 'dart:convert';
import 'package:acbmin_site/entity/Resguardo.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

Future<Resguardo?> crearResguardo(Resguardo resguardo) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  var url = Uri.parse("https://acbmin.lamasoft.org/api/resguardos");
  //var url = Uri.parse("http://localhost:8050/api/resguardos"); // Local

  // Convertir el objeto Resguardo a JSON
  // Asegúrate que tu clase Resguardo tenga el método toJson()
  Map<String, dynamic> resguardoJson = resguardo.toJson();

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(resguardoJson), // Enviar el JSON en el body
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // 201 Created es común para POST
      // Decodificar el resguardo creado (que ahora tendrá folio y otros datos asignados por el backend)
      Map<String, dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));
      return Resguardo.fromJson(jsonData);
    } else {
      print('Error crearResguardo: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null; // Indicar que hubo un error
    }
  } catch (e) {
    print('Error en la solicitud crearResguardo: $e');
    return null;
  }
}
