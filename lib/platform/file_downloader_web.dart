import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Tipo de archivo de Excel (.xlsx).
const tipoExcel = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/// Descarga bytes en Flutter Web sin llevar APIs del navegador a la capa de datos.
/// Funciona igual compilada a JavaScript o a Wasm.
Future<void> downloadFile(Uint8List bytes, String fileName,
    {String tipo = 'application/pdf'}) async {
  final blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: tipo),
  );
  final objectUrl = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = objectUrl
    ..download = fileName
    ..style.display = 'none';

  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  // Safari (iPhone) lee el archivo después del clic: si se libera de inmediato, la
  // descarga puede salir vacía o no salir. Se libera un minuto después.
  Future.delayed(const Duration(minutes: 1), () => web.URL.revokeObjectURL(objectUrl));
}
