import 'dart:convert';

import 'package:acbmin_site/features/entregas_equipo/data/entrega_equipo_service.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('POST usa JWT, omite IDs y toma el folio de la respuesta 201', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode(_responseJson(folio: 108)),
        201,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = EntregaEquipoService(
      innerClient: client,
      tokenProvider: () async => 'jwt-prueba',
      onUnauthorized: () async {},
    );

    final created = await service.create(_editableEntrega());
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    final equipment = (body['equipos'] as List).single as Map;

    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/entregas-equipo');
    expect(captured.headers['authorization'], 'Bearer jwt-prueba');
    expect(body, isNot(contains('folio')));
    expect(body, isNot(contains('estatus')));
    expect(equipment, isNot(contains('id')));
    expect(created.folio, 108);
    service.close();
  });

  test('PUT envía todos los datos editables y el arreglo completo', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('', 204);
    });
    final service = EntregaEquipoService(
      innerClient: client,
      tokenProvider: () async => 'jwt-prueba',
      onUnauthorized: () async {},
    );
    final entrega = _editableEntrega(twoEquipments: true);

    await service.update(55, entrega);
    final body = jsonDecode(captured.body) as Map<String, dynamic>;

    expect(captured.method, 'PUT');
    expect(captured.url.path, '/api/entregas-equipo/55');
    expect(body['capturadoPor'], 'usuario@dominio.mx');
    expect(body['equipos'], hasLength(2));
    expect(body, isNot(contains('folio')));
    service.close();
  });

  test('PDF solicita bytes con JWT y respeta Content-Disposition', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response.bytes(
        const <int>[37, 80, 68, 70],
        200,
        headers: const {
          'content-type': 'application/pdf',
          'content-disposition': 'attachment; filename="entrega_servidor.pdf"',
        },
      );
    });
    final service = EntregaEquipoService(
      innerClient: client,
      tokenProvider: () async => 'jwt-pdf',
      onUnauthorized: () async {},
    );

    final pdf = await service.downloadPdf(7);

    expect(captured.method, 'GET');
    expect(captured.url.path, '/api/entregas-equipo/7/pdf');
    expect(captured.headers['authorization'], 'Bearer jwt-pdf');
    expect(captured.headers['accept'], 'application/pdf');
    expect(pdf.bytes, <int>[37, 80, 68, 70]);
    expect(pdf.fileName, 'entrega_servidor.pdf');
    service.close();
  });

  for (final statusCode in const <int>[400, 401, 404, 500]) {
    test('convierte HTTP $statusCode en un error controlado', () async {
      var clearedExpiredSession = false;
      final service = EntregaEquipoService(
        innerClient: MockClient(
          (_) async => http.Response('{"message":"error"}', statusCode),
        ),
        tokenProvider: () async => 'jwt-prueba',
        onUnauthorized: () async {
          clearedExpiredSession = true;
        },
      );

      await expectLater(
        service.fetchAll(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            statusCode,
          ),
        ),
      );
      expect(clearedExpiredSession, statusCode == 401);
      service.close();
    });
  }
}

/// Documento editable sin folio: representa exactamente lo enviado en POST.
EntregaEquipo _editableEntrega({bool twoEquipments = false}) => EntregaEquipo(
      fechaEntrega: DateTime(2026, 8, 24),
      nombreUsuario: 'María Fernanda Torres Gómez',
      cargo: 'Jefa de Departamento',
      telefonoExtension: 'N/A',
      direccionArea: 'Área de Control de Bienes Muebles e Inmuebles',
      direccionGeneral: 'Dirección General de Recursos Materiales',
      subsecretaria: 'Subsecretaría de Administración',
      elaboradoPor: 'Carlos Eduardo Ramírez Soto',
      capturadoPor: 'usuario@dominio.mx',
      observaciones: 'Sin observaciones',
      equipos: <EquipoEntregado>[
        const EquipoEntregado(
          cantidad: 1,
          descripcion: 'Computadora portátil',
          marca: 'Lenovo',
          modelo: 'ThinkPad E14',
          serie: 'PF-4A92XZ',
          pesa: 'PESA-0001842',
        ),
        if (twoEquipments)
          const EquipoEntregado(
            cantidad: 2,
            descripcion: 'Monitor',
            marca: 'Dell',
            modelo: 'P2422H',
            serie: 'N/A',
            pesa: 'N/A',
          ),
      ],
    );

Map<String, dynamic> _responseJson({required int folio}) => <String, dynamic>{
      ..._editableEntrega().toPayload(),
      'folio': folio,
      'estatus': 'Pendiente',
      'fechaCreacion': '2026-08-24T12:30:00',
      'equipos': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          ..._editableEntrega().equipos.single.toPayload(),
        },
      ],
    };
