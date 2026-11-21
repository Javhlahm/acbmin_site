import 'dart:typed_data';

import 'package:excel/excel.dart';

import 'file_downloader.dart';

/// Descarga un libro de Excel.
/// No se usa excel.save(): el paquete excel descarga con dart:html, que no existe
/// cuando la app está compilada a Wasm, y entonces no hace nada.
Future<void> descargarExcel(Excel libro, String nombreArchivo) async {
  final bytes = libro.encode();
  if (bytes == null) {
    throw StateError('No se pudo generar el archivo de Excel');
  }
  await downloadFile(Uint8List.fromList(bytes), nombreArchivo, tipo: tipoExcel);
}
