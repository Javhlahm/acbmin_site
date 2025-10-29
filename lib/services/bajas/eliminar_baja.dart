import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // para utf8.decode

Future<bool> eliminarBaja(int folio) async {
  final token = await authService.getToken();
  if (token == null) {
    print("Error eliminarBaja: Token nulo.");
    return false;
  }
  final headers = {
    'Authorization': 'Bearer $token',
  };
  // var url =
  //   Uri.parse("https://acbmin.lamasoft.org/api/autoalmacen/bajas/$folio");
  var url = Uri.parse("http://localhost:8050/api/bajas/$folio"); // Local

  try {
    var response = await http.delete(
      // Usar DELETE
      url,
      headers: headers,
    );

    // 204 No Content es éxito para DELETE sin body de respuesta
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; // Éxito
    } else {
      print('Error eliminarBaja: ${response.statusCode}');
      try {
        // Intentar decodificar el cuerpo del error
        print('Response body: ${utf8.decode(response.bodyBytes)}');
      } catch (_) {
        print('Response body: (No se pudo decodificar)');
      }
      return false; // Error
    }
  } catch (e) {
    print('Error en la solicitud eliminarBaja: $e');
    return false;
  }
}
