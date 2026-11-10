import 'dart:convert';
import 'dart:typed_data';

import 'package:acbmin_site/config/api_config.dart';
import 'package:acbmin_site/features/almacen_general/domain/almacen_general.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/network/authenticated_http_client.dart';
import 'package:http/http.dart' as http;

/// Comunicación con la API del Almacén General (/almacen-general).
///
/// El cliente agrega el JWT de la sesión a cada petición. Si la API rechaza
/// algo (por ejemplo, una salida mayor a la existencia), se muestra el mensaje
/// que manda la API.
class AlmacenGeneralService {
  AlmacenGeneralService({
    http.Client? clienteInterno,
    TokenProvider? tokenProvider,
  }) : _cliente = AuthenticatedHttpClient(
          inner: clienteInterno,
          tokenProvider: tokenProvider,
        );

  final http.Client _cliente;

  static const String _ruta = 'almacen-general';

  /// Años con vista: 2024, 2025, 2026 y los que ya tengan compras.
  Future<List<int>> obtenerAnios() async {
    final respuesta = await _enviar(
        () => _cliente.get(ApiConfig.endpoint('$_ruta/anios')));
    _revisar(respuesta, 'consultar los años');
    return (_json(respuesta) as List)
        .map((anio) => (anio as num).toInt())
        .toList();
  }

  // ---------- Compras ----------

  Future<List<CompraAlmacen>> obtenerCompras(int anio) async {
    final respuesta = await _enviar(() =>
        _cliente.get(ApiConfig.endpoint('$_ruta/compras?anio=$anio')));
    _revisar(respuesta, 'consultar las compras');
    return (_json(respuesta) as List)
        .map((c) => CompraAlmacen.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();
  }

  Future<CompraAlmacen> crearCompra(CompraAlmacen compra) async {
    final respuesta = await _enviar(() => _cliente.post(
          ApiConfig.endpoint('$_ruta/compras'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(compra.toPayload()),
        ));
    _revisar(respuesta, 'guardar la compra');
    return CompraAlmacen.fromJson(_json(respuesta) as Map<String, dynamic>);
  }

  Future<CompraAlmacen> actualizarCompra(int id, CompraAlmacen compra) async {
    final respuesta = await _enviar(() => _cliente.put(
          ApiConfig.endpoint('$_ruta/compras/$id'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(compra.toPayload()),
        ));
    _revisar(respuesta, 'guardar la compra');
    return CompraAlmacen.fromJson(_json(respuesta) as Map<String, dynamic>);
  }

  Future<void> eliminarCompra(int id) async {
    final respuesta = await _enviar(
        () => _cliente.delete(ApiConfig.endpoint('$_ruta/compras/$id')));
    _revisar(respuesta, 'eliminar la compra');
  }

  /// PDF de la compra. Regresa los bytes y el nombre del archivo.
  Future<(Uint8List, String)> descargarPdf(CompraAlmacen compra) async {
    final respuesta = await _enviar(() => _cliente.get(
          ApiConfig.endpoint('$_ruta/compras/${compra.id}/pdf'),
          headers: const {'Accept': 'application/pdf'},
        ));
    _revisar(respuesta, 'generar el PDF');
    final factura = compra.numeroFactura.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '_');
    return (respuesta.bodyBytes, 'compra_factura_$factura.pdf');
  }

  // ---------- Vales de salida ----------

  /// Artículos con existencia de todas las compras, para armar un vale.
  Future<List<ArticuloDisponible>> obtenerArticulosDisponibles() async {
    final respuesta = await _enviar(() =>
        _cliente.get(ApiConfig.endpoint('$_ruta/articulos-disponibles')));
    _revisar(respuesta, 'consultar los artículos disponibles');
    return (_json(respuesta) as List)
        .map((a) =>
            ArticuloDisponible.fromJson(Map<String, dynamic>.from(a as Map)))
        .toList();
  }

  Future<List<ValeSalida>> obtenerVales(int anio) async {
    final respuesta = await _enviar(() =>
        _cliente.get(ApiConfig.endpoint('$_ruta/salidas?anio=$anio')));
    _revisar(respuesta, 'consultar las salidas');
    return (_json(respuesta) as List)
        .map((v) => ValeSalida.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList();
  }

  /// Guarda el vale; la API le asigna el folio y descuenta la existencia.
  Future<ValeSalida> registrarVale(ValeSalida vale) async {
    final respuesta = await _enviar(() => _cliente.post(
          ApiConfig.endpoint('$_ruta/salidas'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(vale.toPayload()),
        ));
    _revisar(respuesta, 'registrar la salida');
    return ValeSalida.fromJson(_json(respuesta) as Map<String, dynamic>);
  }

  /// Borra el vale; la API regresa el material a la existencia.
  Future<void> eliminarVale(int id) async {
    final respuesta = await _enviar(
        () => _cliente.delete(ApiConfig.endpoint('$_ruta/salidas/$id')));
    _revisar(respuesta, 'eliminar el vale de salida');
  }

  /// PDF del vale de salida. Regresa los bytes y el nombre del archivo.
  Future<(Uint8List, String)> descargarPdfVale(ValeSalida vale) async {
    final respuesta = await _enviar(() => _cliente.get(
          ApiConfig.endpoint('$_ruta/salidas/${vale.id}/pdf'),
          headers: const {'Accept': 'application/pdf'},
        ));
    _revisar(respuesta, 'generar el PDF');
    return (
      respuesta.bodyBytes,
      'vale_salida_${vale.folioTexto.replaceAll('/', '-')}.pdf'
    );
  }

  // ---------- Ayudas ----------

  // Convierte una falla de red en un mensaje entendible.
  Future<http.Response> _enviar(Future<http.Response> Function() peticion) async {
    try {
      return await peticion();
    } on http.ClientException {
      throw const ApiException('No fue posible comunicarse con la API.');
    }
  }

  Object? _json(http.Response respuesta) =>
      jsonDecode(utf8.decode(respuesta.bodyBytes));

  void _revisar(http.Response respuesta, String accion) {
    final codigo = respuesta.statusCode;
    if (codigo >= 200 && codigo < 300) return;

    final mensaje = switch (codigo) {
      // En un 400 la API explica qué está mal (factura repetida, sin existencia...).
      400 => _mensajeDeLaApi(respuesta) ?? 'Revisa los datos capturados.',
      401 => 'Tu sesión expiró. Inicia sesión nuevamente.',
      404 => 'El registro ya no existe. Actualiza la pantalla.',
      _ => 'No fue posible $accion ($codigo). Intenta más tarde.',
    };
    throw ApiException(mensaje, statusCode: codigo);
  }

  /// Micronaut manda el mensaje en _embedded.errors[0].message.
  String? _mensajeDeLaApi(http.Response respuesta) {
    try {
      final cuerpo = _json(respuesta);
      if (cuerpo is! Map) return null;
      final errores = (cuerpo['_embedded'] as Map?)?['errors'];
      if (errores is List && errores.isNotEmpty) {
        return (errores.first as Map)['message']?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void close() => _cliente.close();
}
