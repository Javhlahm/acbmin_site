import 'dart:convert';

import 'package:acbmin_site/features/almacen_general/data/almacen_general_service.dart';
import 'package:acbmin_site/features/almacen_general/domain/almacen_general.dart';
import 'package:acbmin_site/features/almacen_general/presentation/almacen_general_page.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Compra como la regresa la API
Map<String, dynamic> _compraJson({int id = 7, int anio = 2025}) => {
      'id': id,
      'fechaFactura': '$anio-03-10',
      'anio': anio,
      'numeroFactura': 'F-100',
      'ordenCompra': 'OC-55',
      'proveedor': 'Papelería del Centro',
      'articulos': [
        {
          'id': 100,
          'compraId': id,
          'descripcion': 'Hojas blancas',
          'marca': 'Scribe',
          'cantidad': 10,
          'precioUnitario': 120.0,
          'existencia': 6,
        },
        {
          'id': 101,
          'compraId': id,
          'descripcion': 'Plumas',
          'marca': null,
          'cantidad': 5,
          'precioUnitario': null,
          'existencia': 5,
        },
      ],
    };

http.Response _json(Object cuerpo, [int codigo = 200]) => http.Response(
      jsonEncode(cuerpo),
      codigo,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );

AlmacenGeneralService _servicio(
        Future<http.Response> Function(http.Request) responder) =>
    AlmacenGeneralService(
      clienteInterno: MockClient(responder),
      tokenProvider: () async => 'jwt-prueba',
    );

void main() {
  group('Modelo', () {
    test('lee la compra, calcula importes, total y salidas', () {
      final compra = CompraAlmacen.fromJson(_compraJson());

      expect(compra.anio, 2025);
      expect(compra.articulos.first.importe, 1200.0);
      expect(compra.articulos.first.salidas, 4);
      expect(compra.articulos.last.marca, '');
      expect(compra.articulos.last.importe, isNull);
      expect(compra.total, 1200.0);
      expect(compra.tieneSalidas, isTrue);
    });

    test('al guardar manda el id de los artículos pero no la existencia', () {
      final payload = CompraAlmacen.fromJson(_compraJson()).toPayload();
      final articulo = (payload['articulos'] as List).first as Map;

      expect(payload['fechaFactura'], '2025-03-10');
      expect(payload, isNot(contains('anio')));
      expect(articulo['id'], 100);
      expect(articulo, isNot(contains('existencia')));
    });

    test('lee el vale con su folio y la factura de origen de cada material', () {
      final vale = ValeSalida.fromJson({
        'id': 3,
        'anio': 2026,
        'folio': 12,
        'fecha': '2026-11-09',
        'recibe': 'María Gómez',
        'area': 'Recursos Humanos',
        'articulos': [
          {'articuloId': 100, 'compraId': 7, 'cantidad': 3, 'descripcion': 'Hojas blancas', 'numeroFactura': 'F-100', 'ordenCompra': 'OC-55', 'proveedor': 'Papelería del Centro'},
          {'articuloId': 101, 'compraId': 7, 'cantidad': 1, 'descripcion': 'Plumas', 'numeroFactura': 'F-100'},
          {'articuloId': 200, 'compraId': 9, 'cantidad': 5, 'descripcion': 'Foco LED', 'numeroFactura': 'A-77'},
        ],
      });

      expect(vale.folioTexto, '0012/2026');
      expect(vale.facturas, ['F-100', 'A-77']);
      expect(vale.resumen, '3 × Hojas blancas, 1 × Plumas, 5 × Foco LED');
      expect(vale.coincideCon('a-77'), isTrue);
      expect(vale.coincideCon('0012'), isTrue);
      expect(vale.coincideCon('tóner'), isFalse);

      // A la API solo se manda el artículo y la cantidad de cada material.
      final payload = vale.toPayload();
      expect(payload['fecha'], '2026-11-09');
      expect((payload['articulos'] as List).first, {'articuloId': 100, 'cantidad': 3});
    });

    test('busca por factura, proveedor y descripción', () {
      final compra = CompraAlmacen.fromJson(_compraJson());

      expect(compra.coincideCon('f-100'), isTrue);
      expect(compra.coincideCon('centro'), isTrue);
      expect(compra.coincideCon('plumas'), isTrue);
      expect(compra.coincideCon('tóner'), isFalse);
    });
  });

  group('Servicio', () {
    test('consulta las compras del año con el JWT', () async {
      late http.Request peticion;
      final servicio = _servicio((request) async {
        peticion = request;
        return _json([_compraJson()]);
      });

      final compras = await servicio.obtenerCompras(2025);

      expect(peticion.url.path, '/api/almacen-general/compras');
      expect(peticion.url.queryParameters['anio'], '2025');
      expect(peticion.headers['authorization'], 'Bearer jwt-prueba');
      expect(compras.single.numeroFactura, 'F-100');
    });

    test('muestra el mensaje de la API cuando rechaza una salida', () async {
      final servicio = _servicio((_) async => _json({
            'message': 'Bad Request',
            '_embedded': {
              'errors': [
                {'message': 'Solo hay 6 en existencia de "Hojas blancas"'}
              ]
            },
          }, 400));

      expect(
        () => servicio.registrarVale(ValeSalida(
          fecha: DateTime(2026, 11, 6),
          recibe: 'Juan',
          materiales: const [MaterialSalida(articuloId: 100, cantidad: 20)],
        )),
        throwsA(isA<ApiException>().having((e) => e.message, 'message',
            'Solo hay 6 en existencia de "Hojas blancas"')),
      );
    });
  });

  group('Pantalla', () {
    testWidgets('muestra una pestaña por año y las compras del año',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final servicio = _servicio((request) async {
        final ruta = request.url.path;
        if (ruta.endsWith('/anios')) return _json([2024, 2025, 2026]);
        if (ruta.endsWith('/compras')) {
          final anio = int.parse(request.url.queryParameters['anio']!);
          return _json(anio == 2025 ? [_compraJson()] : []);
        }
        return _json([]); // salidas
      });

      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => AlmacenGeneralPage(servicio: servicio),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);

      // Arranca en el año actual (2026 o el último), que no tiene compras.
      expect(find.textContaining('Aún no hay compras'), findsOneWidget);

      await tester.tap(find.text('2025'));
      await tester.pumpAndSettle();

      expect(find.text('F-100'), findsOneWidget);
      expect(find.text('Papelería del Centro'), findsOneWidget);
      expect(find.text('2 artículos'), findsOneWidget);
      expect(find.textContaining('Total comprado en 2025'), findsOneWidget);
    });
  });
}
