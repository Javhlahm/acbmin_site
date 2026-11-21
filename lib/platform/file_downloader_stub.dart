import 'dart:typed_data';

/// Tipo de archivo de Excel (.xlsx).
const tipoExcel = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/// Implementación segura para plataformas donde aún no existe descarga local.
Future<void> downloadFile(Uint8List bytes, String fileName,
    {String tipo = 'application/pdf'}) {
  throw UnsupportedError(
      'La descarga de archivos solo está habilitada en web.');
}
