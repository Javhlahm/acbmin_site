import 'dart:typed_data'; // Para manejar los bytes del PDF
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es web
import 'dart:convert'; // Para utf8.decode en el error

// Importa package:web para la lógica web
import 'package:web/web.dart' as web;
// Necesitamos js_interop para convertir Uint8List
import 'dart:js_interop';

// Para no-web (opcional, si implementas la descarga/apertura móvil/desktop)
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';

// Función para llamar al endpoint del reporte y manejar la descarga/apertura
Future<bool> generarYMostrarReporteResguardo(int folio) async {
  final token = await authService.getToken();
  if (token == null) {
    print('Error: Token no encontrado para generar reporte.');
    return false;
  }

  final headers = {
    'Authorization': 'Bearer $token',
  };

  // final url = Uri.parse("https://acbmin.lamasoft.org/api/resguardos/" +
  //    folio.toString() +
  //   "/pdf");
  final url = Uri.parse("http://localhost:8050/api/resguardos/" +
      folio.toString() +
      "/pdf"); // Para pruebas locales

  try {
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Uint8List pdfBytes = response.bodyBytes;
      final String fileName =
          'Resguardo_RICB-${folio.toString().padLeft(4, '0')}.pdf';

      // --- VERIFICACIÓN DE PLATAFORMA ---
      if (kIsWeb) {
        // --- LÓGICA SOLO PARA WEB (usa package:web y js_interop) ---
        try {
          // 1. Convertir Uint8List a JSTypedArray (que es un BlobPart)
          final jsBytes = pdfBytes.toJS;

          // 2. Crear un Blob directamente con una lista que contiene el JSTypedArray
          //    El constructor de Blob acepta JSArray<BlobPart>.
          //    Creamos un JSArray que contiene nuestro jsBytes.
          final blobParts = [jsBytes].toJS; // Convierte la lista Dart a JSArray
          final blob =
              web.Blob(blobParts, web.BlobPropertyBag(type: 'application/pdf'));

          // 3. Crear una URL para el Blob
          final url = web.URL.createObjectURL(blob);

          // 4. Crear un elemento 'a' (HTMLAnchorElement)
          final anchor =
              web.document.createElement('a') as web.HTMLAnchorElement
                ..href = url
                ..style.display = 'none' // Ocultarlo
                ..download = fileName; // Establecer el nombre de descarga

          // 5. Añadir el ancla al body, simular clic y removerla
          web.document.body!.appendChild(anchor);
          anchor.click();
          web.document.body!.removeChild(anchor);

          // 6. Revocar la URL del objeto para liberar memoria
          web.URL.revokeObjectURL(url);

          print('Descarga iniciada en web para $fileName usando package:web');
          return true; // Éxito en web
        } catch (e) {
          print(
              "Error al intentar descargar el PDF en web usando package:web: $e");
          return false;
        }
        // --- FIN LÓGICA WEB ---
      } else {
        // --- LÓGICA PARA NO-WEB (Móvil/Desktop - Sin cambios) ---
        print(
            "Plataforma no web detectada. La descarga/apertura automática no está implementada.");
        // (El código comentado con path_provider y open_filex permanece igual)
        /*
        try {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);
          print('Archivo guardado en: $filePath');
          final result = await OpenFilex.open(filePath);
          print('Resultado de abrir archivo: ${result.message}');
          return result.type == ResultType.done;
        } catch (e) {
          print("Error al guardar/abrir PDF en móvil/desktop: $e");
          return false;
        }
        */
        return false;
        // --- FIN LÓGICA NO-WEB ---
      }
    } else {
      // Error desde la API
      print('Error al generar reporte: ${response.statusCode}');
      try {
        print('Response error body: ${utf8.decode(response.bodyBytes)}');
      } catch (_) {
        print('Response error body: (No se pudo decodificar como texto)');
      }
      return false;
    }
  } catch (e) {
    // Error en la solicitud HTTP
    print('Error en la solicitud generarYMostrarReporteResguardo: $e');
    return false;
  }
}

// Ya NO necesitamos la extensión BlobConversion
