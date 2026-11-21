// En la web se usa la versión que descarga con el navegador; en otras plataformas, la vacía.
// Ojo: se pregunta por dart.library.js_interop y no por dart.library.html, porque compilada a
// Wasm la app no tiene dart:html y caería en la versión vacía (las descargas no harían nada).
export 'file_downloader_stub.dart'
    if (dart.library.js_interop) 'file_downloader_web.dart';
