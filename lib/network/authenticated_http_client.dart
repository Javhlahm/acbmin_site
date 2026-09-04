import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

typedef TokenProvider = Future<String?> Function();

/// Cliente HTTP compartido que agrega el JWT a cada petición saliente.
///
/// La clase envuelve a `http.Client` para poder inyectar un cliente falso en
/// pruebas sin duplicar la lógica de autenticación en cada servicio.
class AuthenticatedHttpClient extends http.BaseClient {
  AuthenticatedHttpClient({
    http.Client? inner,
    TokenProvider? tokenProvider,
    Future<void> Function()? onUnauthorized,
  })  : _inner = inner ?? http.Client(),
        _tokenProvider = tokenProvider ?? authService.getToken,
        _onUnauthorized = onUnauthorized ?? authService.deleteToken;

  final http.Client _inner;
  final TokenProvider _tokenProvider;
  final Future<void> Function() _onUnauthorized;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _tokenProvider();
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(
        'No existe una sesión activa. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }

    // Cada endpoint autenticado recibe el mismo encabezado Bearer.
    request.headers['Authorization'] = 'Bearer $token';
    request.headers.putIfAbsent('Accept', () => 'application/json');

    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      // Un JWT rechazado se elimina para no reutilizar una sesión expirada.
      await _onUnauthorized();
    }
    return response;
  }

  @override
  void close() => _inner.close();
}
