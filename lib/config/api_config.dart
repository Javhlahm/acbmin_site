/// Configuración única para construir las rutas de la API.
///
/// En producción, si frontend y backend comparten dominio, el valor relativo
/// `/api` funciona sin configuración adicional. Para desarrollo u otro host se
/// puede compilar con:
/// `--dart-define=API_BASE_URL=https://servidor.example/api`.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '/api',
  );

  /// Une la URL base con una ruta relativa sin duplicar diagonales.
  static Uri endpoint(String relativePath) {
    final normalizedBase = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final normalizedPath = relativePath.trim().replaceFirst(RegExp(r'^/+'), '');

    if (normalizedBase.isEmpty) {
      throw StateError('API_BASE_URL no puede estar vacío.');
    }
    return Uri.parse('$normalizedBase/$normalizedPath');
  }
}
