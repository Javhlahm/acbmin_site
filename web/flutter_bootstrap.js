{{flutter_js}}
{{flutter_build_config}}

// Arranque de la app: es la plantilla de Flutter con un solo ajuste.
// wasmAllowList: además de Chrome y Edge (blink), se usa WebAssembly en Safari
// (webkit) y Firefox (gecko). Si el navegador no lo soporta, Flutter usa JavaScript.
_flutter.loader.load({
  config: {
    wasmAllowList: { blink: true, webkit: true, gecko: true },
  },
  // Service worker de limpieza: quita el que dejaron versiones anteriores.
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
