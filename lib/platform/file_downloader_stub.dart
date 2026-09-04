import 'dart:typed_data';

/// Implementación segura para plataformas donde aún no existe descarga local.
Future<void> downloadFile(Uint8List bytes, String fileName) {
  throw UnsupportedError(
      'La descarga de archivos solo está habilitada en web.');
}
