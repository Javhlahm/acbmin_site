import 'dart:typed_data';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web; // Usar package:web
import 'dart:js_interop'; // Para extension .toJS
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
  //final url = Uri.parse(
  //  "https://acbmin.lamasoft.org/api/bajas/" + folio.toString() +"/pdf");
  final url = Uri.parse(
      "http://localhost:8050/api/bajas/" + folio.toString() + "/pdf"); // Local

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
          final jsBytes = pdfBytes.toJS;
          final blobParts = [jsBytes].toJS;
          final blob =
              web.Blob(blobParts, web.BlobPropertyBag(type: 'application/pdf'));
          final url = web.URL.createObjectURL(blob);
          final anchor =
              web.document.createElement('a') as web.HTMLAnchorElement
                ..href = url
                ..style.display = 'none'
                ..download = fileName;
          web.document.body!.appendChild(anchor);
          anchor.click();
          web.document.body!.removeChild(anchor);
          web.URL.revokeObjectURL(url);
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
