import 'package:acbmin_site/config/api_config.dart';
import 'package:acbmin_site/platform/file_downloader.dart';
import 'dart:typed_data';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert'; // Para utf8.decode en error

// Para no-web (opcional)
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';

Future<bool> generarYMostrarReporteBaja(int folio) async {
  final token = await authService.getToken();
  if (token == null) {
    print('Error: Token no encontrado para generar reporte de baja.');
    return false;
  }

  final headers = {'Authorization': 'Bearer $token'};
  final url = ApiConfig.endpoint("bajas/" + folio.toString() + "/pdf");
  //final url = Uri.parse(
  //  "http://localhost:8050/bajas/" + folio.toString() + "/pdf"); // Local

  try {
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Uint8List pdfBytes = response.bodyBytes;
      // Generar nombre de archivo específico para bajas
      final String fileName =
          'Baja_Bien_${folio.toString().padLeft(4, '0')}.pdf';

      if (kIsWeb) {
        // --- Lógica Web con package:web ---
        try {
          // Descarga común: funciona igual compilada a JavaScript o a Wasm.
          await downloadFile(pdfBytes, fileName);
          print('Descarga iniciada en web para $fileName');
          return true;
        } catch (e) {
          print("Error al descargar PDF de baja en web: $e");
          return false;
        }
        // --- Fin Web ---
      } else {
        // --- Lógica No-Web (Comentada) ---
        print(
            "Plataforma no web detectada. Descarga/apertura no implementada.");
        /*
        try {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);
          print('Archivo guardado en: $filePath');
          final result = await OpenFilex.open(filePath);
          return result.type == ResultType.done;
        } catch (e) {
          print("Error al guardar/abrir PDF de baja en móvil/desktop: $e");
          return false;
        }
        */
        return false;
        // --- Fin No-Web ---
      }
    } else {
      print('Error al generar reporte de baja: ${response.statusCode}');
      try {
        print('Response error body: ${utf8.decode(response.bodyBytes)}');
      } catch (_) {
        print('Response error body: (No decodificable)');
      }
      return false;
    }
  } catch (e) {
    print('Error en la solicitud generarYMostrarReporteBaja: $e');
    return false;
  }
}
