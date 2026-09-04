import 'dart:typed_data';

import 'package:acbmin_site/features/entregas_equipo/data/entrega_equipo_service.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/features/entregas_equipo/presentation/entrega_equipo_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('oculta estatus y permite consultar todos los equipos',
      (tester) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: EntregaEquipoListPage(repository: _ListRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estatus'), findsNothing);
    expect(find.text('Pendiente'), findsNothing);
    expect(find.text('2 equipos'), findsOneWidget);
    // Las descripciones se reservan para el detalle y ya no se trunca la primera.
    expect(find.text('Laptop para diseño'), findsNothing);
    expect(find.text('Monitor de alta resolución'), findsNothing);

    await tester.tap(find.text('2 equipos'));
    await tester.pumpAndSettle();

    expect(find.text('Equipos de la entrega 0042'), findsOneWidget);
    expect(find.text('Equipo 1: Laptop para diseño'), findsOneWidget);
    expect(find.text('Equipo 2: Monitor de alta resolución'), findsOneWidget);
    expect(find.text('Serie: LAP-001'), findsOneWidget);
    expect(find.text('PESA: PESA-002'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el acceso al detalle también funciona en móvil', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: EntregaEquipoListPage(repository: _ListRepository())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('2 equipos'));
    await tester.pumpAndSettle();

    expect(find.text('Equipos de la entrega 0042'), findsOneWidget);
    expect(find.text('Equipo 1: Laptop para diseño'), findsOneWidget);
    expect(find.text('Equipo 2: Monitor de alta resolución'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Repositorio en memoria para probar el listado sin modificar la API real.
class _ListRepository implements EntregaEquipoRepository {
  @override
  Future<List<EntregaEquipo>> fetchAll() async => <EntregaEquipo>[_entrega];

  @override
  Future<EntregaEquipo> fetchByFolio(int folio) async => _entrega;

  @override
  Future<EntregaEquipo> create(EntregaEquipo entrega) async => entrega;

  @override
  Future<void> update(int folio, EntregaEquipo entrega) async {}

  @override
  Future<void> delete(int folio) async {}

  @override
  Future<EntregaEquipoPdf> downloadPdf(int folio) async => EntregaEquipoPdf(
        bytes: Uint8List(0),
        fileName: 'entrega.pdf',
      );
}

final EntregaEquipo _entrega = EntregaEquipo(
  folio: 42,
  fechaEntrega: DateTime(2026, 8, 25),
  nombreUsuario: 'Persona receptora',
  cargo: 'Diseño',
  telefonoExtension: 'N/A',
  direccionArea: 'Área de prueba',
  direccionGeneral: 'Dirección de prueba',
  subsecretaria: 'Subsecretaría de prueba',
  elaboradoPor: 'Usuario de prueba',
  capturadoPor: 'usuario@dominio.mx',
  observaciones: 'Sin observaciones',
  estatus: 'Pendiente',
  fechaCreacion: DateTime(2026, 8, 25),
  equipos: const <EquipoEntregado>[
    EquipoEntregado(
      cantidad: 1,
      descripcion: 'Laptop para diseño',
      marca: 'Marca A',
      modelo: 'Modelo A',
      serie: 'LAP-001',
      pesa: 'PESA-001',
    ),
    EquipoEntregado(
      cantidad: 2,
      descripcion: 'Monitor de alta resolución',
      marca: 'Marca B',
      modelo: 'Modelo B',
      serie: 'MON-002',
      pesa: 'PESA-002',
    ),
  ],
);
