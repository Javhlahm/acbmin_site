import 'dart:convert';
import 'dart:typed_data';

import 'package:acbmin_site/config/api_config.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/network/authenticated_http_client.dart';
import 'package:http/http.dart' as http;

/// Resultado binario del endpoint PDF junto con el nombre sugerido.
class EntregaEquipoPdf {
  const EntregaEquipoPdf({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// Contrato que permite sustituir la API real por dobles de prueba.
abstract interface class EntregaEquipoRepository {
  Future<List<EntregaEquipo>> fetchAll();
  Future<EntregaEquipo> fetchByFolio(int folio);
  Future<EntregaEquipo> create(EntregaEquipo entrega);
  Future<void> update(int folio, EntregaEquipo entrega);
  Future<void> delete(int folio);
  Future<EntregaEquipoPdf> downloadPdf(int folio);
}

/// Implementación REST del módulo Entrega de Equipo.
///
/// Todas las rutas son relativas a [ApiConfig.baseUrl] y el cliente agrega el
/// JWT automáticamente. Este servicio no conoce entidades de otros módulos.
class EntregaEquipoService implements EntregaEquipoRepository {
  EntregaEquipoService({
    http.Client? innerClient,
    TokenProvider? tokenProvider,
    Future<void> Function()? onUnauthorized,
  }) : _client = AuthenticatedHttpClient(
          inner: innerClient,
          tokenProvider: tokenProvider,
          onUnauthorized: onUnauthorized,
        );

  final http.Client _client;

  static const String _resourcePath = 'entregas-equipo';

  @override
  Future<List<EntregaEquipo>> fetchAll() async {
    final response = await _get(ApiConfig.endpoint(_resourcePath));
    _ensureSuccess(response, expected: const {200}, action: 'consultar');

    final decoded = _decodeJson(response);
    if (decoded is! List) {
      throw const ApiException('La API devolvió un listado inválido.');
    }
    return decoded
        .map((item) => EntregaEquipo.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList(growable: false);
  }

  @override
  Future<EntregaEquipo> fetchByFolio(int folio) async {
    final response = await _get(ApiConfig.endpoint('$_resourcePath/$folio'));
    _ensureSuccess(response, expected: const {200}, action: 'consultar');
    return EntregaEquipo.fromJson(_decodeObject(response));
  }

  @override
  Future<EntregaEquipo> create(EntregaEquipo entrega) async {
    final response = await _post(
      ApiConfig.endpoint(_resourcePath),
      body: entrega.toPayload(),
    );
    // El contrato exige 201 para asegurar que el folio proviene del alta.
    _ensureSuccess(response, expected: const {201}, action: 'crear');

    final created = EntregaEquipo.fromJson(_decodeObject(response));
    if (created.folio == null) {
      throw const ApiException(
        'La API creó la entrega pero no devolvió el folio asignado.',
      );
    }
    return created;
  }

  @override
  Future<void> update(int folio, EntregaEquipo entrega) async {
    final response = await _put(
      ApiConfig.endpoint('$_resourcePath/$folio'),
      body: entrega.toPayload(),
    );
    _ensureSuccess(response, expected: const {200, 204}, action: 'actualizar');
  }

  @override
  Future<void> delete(int folio) async {
    final response = await _delete(ApiConfig.endpoint('$_resourcePath/$folio'));
    _ensureSuccess(response, expected: const {200, 204}, action: 'eliminar');
  }

  @override
  Future<EntregaEquipoPdf> downloadPdf(int folio) async {
    final response = await _get(
      ApiConfig.endpoint('$_resourcePath/$folio/pdf'),
      accept: 'application/pdf',
    );
    _ensureSuccess(response, expected: const {200}, action: 'descargar el PDF');

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (!contentType.contains('application/pdf')) {
      throw const ApiException('La API no devolvió un archivo PDF válido.');
    }

    return EntregaEquipoPdf(
      bytes: response.bodyBytes,
      fileName: _resolveFileName(response.headers, folio),
    );
  }

  Future<http.Response> _get(Uri uri, {String? accept}) async {
    try {
      return await _client.get(
        uri,
        headers: accept == null ? null : {'Accept': accept},
      );
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException('No fue posible comunicarse con la API.');
    }
  }

  Future<http.Response> _post(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    try {
      return await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException('No fue posible comunicarse con la API.');
    }
  }

  Future<http.Response> _put(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    try {
      return await _client.put(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException('No fue posible comunicarse con la API.');
    }
  }

  Future<http.Response> _delete(Uri uri) async {
    try {
      return await _client.delete(uri);
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException('No fue posible comunicarse con la API.');
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = _decodeJson(response);
    if (decoded is! Map) {
      throw const ApiException('La API devolvió un registro inválido.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('La API devolvió una respuesta JSON inválida.');
    }
  }

  void _ensureSuccess(
    http.Response response, {
    required Set<int> expected,
    required String action,
  }) {
    if (expected.contains(response.statusCode)) return;

    final message = switch (response.statusCode) {
      400 => 'Los datos enviados no son válidos. Revisa el formulario.',
      401 => 'Tu sesión expiró. Inicia sesión nuevamente.',
      404 => 'La entrega solicitada no existe.',
      >= 500 => 'El servidor no pudo $action la entrega. Intenta más tarde.',
      _ => 'No fue posible $action la entrega (${response.statusCode}).',
    };
    throw ApiException(message, statusCode: response.statusCode);
  }

  String _resolveFileName(Map<String, String> headers, int folio) {
    final disposition = headers['content-disposition'];
    if (disposition != null) {
      final match = RegExp(
        r'''filename\*?=(?:UTF-8''|["'])?([^"';]+)''',
        caseSensitive: false,
      ).firstMatch(disposition);
      if (match != null) {
        final decoded = Uri.decodeComponent(match.group(1)!.trim());
        // Se elimina cualquier ruta enviada por el servidor y se conserva el nombre.
        final safeName = decoded.split(RegExp(r'[/\\]')).last;
        if (safeName.toLowerCase().endsWith('.pdf')) return safeName;
      }
    }
    return 'entrega_equipo_${folio.toString().padLeft(4, '0')}.pdf';
  }

  /// Libera el cliente cuando la página creó esta instancia del servicio.
  void close() => _client.close();
}
