import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

Future<bool> eliminarResguardo(int folio) async {
  final token = await authService.getToken();
  final headers = {
    'Authorization': 'Bearer $token', // Solo necesita autorización
  };
  // var url = Uri.parse("https://acbmin.lamasoft.org/api/resguardos/$folio");
  var url = Uri.parse("http://localhost:8050/api/resguardos/$folio"); // Local

  try {
    var response = await http.delete(
      // Usar DELETE
      url,
      headers: headers,
    );

    // Usualmente DELETE retorna 200 OK o 204 No Content en éxito
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; // Éxito
    } else {
      print('Error eliminarResguardo: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false; // Error
    }
  } catch (e) {
    print('Error en la solicitud eliminarResguardo: $e');
    return false;
  }
}
