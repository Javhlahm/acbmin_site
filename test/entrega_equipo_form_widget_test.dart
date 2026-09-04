import 'dart:typed_data';

import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/features/entregas_equipo/data/entrega_equipo_service.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/features/entregas_equipo/presentation/entrega_equipo_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    usuarioGlobal = Usuario(
      nombre: 'Usuario de prueba',
      email: 'usuario@dominio.mx',
      roles: const <String>['admin'],
    );
  });
  tearDown(() => usuarioGlobal = null);

  testWidgets('el formulario nuevo es responsive y comienza con un equipo',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in const <Size>[
      Size(390, 844),
      Size(844, 390),
      Size(768, 1024),
      Size(1366, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          home: EntregaEquipoFormPage(repository: _FormRepository()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1. Datos de la entrega'), findsOneWidget);
      expect(find.text('2. Equipos entregados'), findsOneWidget);
      expect(find.text('Equipo 1'), findsOneWidget);
      expect(find.text('Capturado por'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Viewport: $size');
    }
  });

  testWidgets('muestra validaciones y permite agregar equipos dinámicos',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: EntregaEquipoFormPage(repository: _FormRepository())),
    );
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(ElevatedButton, 'Agregar equipo');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pump();
    expect(find.text('Equipo 2'), findsOneWidget);

    final saveButton = find.widgetWithText(ElevatedButton, 'Crear entrega');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    // Comprueba validaciones reales del formulario, no solo la lógica de dominio.
    expect(find.text('Nombre del usuario es obligatorio.'), findsOneWidget);
    expect(find.text('Cargo es obligatorio.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el formulario de edición no muestra el estatus', (tester) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: EntregaEquipoFormPage(
          folio: 42,
          repository: _FormRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // El backend puede conservar el dato, pero la interfaz no debe exponerlo.
    expect(find.text('Datos asignados por el servidor'), findsOneWidget);
    expect(find.text('Estatus'), findsNothing);
    expect(find.text('Pendiente'), findsNothing);
    expect(find.text('Fecha de creación'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Repositorio sin red para renderizar y validar el formulario de alta.
class _FormRepository implements EntregaEquipoRepository {
  @override
  Future<EntregaEquipo> create(EntregaEquipo entrega) async => entrega;

  @override
  Future<void> delete(int folio) async {}

  @override
  Future<EntregaEquipoPdf> downloadPdf(int folio) async => EntregaEquipoPdf(
        bytes: Uint8List(0),
        fileName: 'entrega.pdf',
      );

  @override
  Future<List<EntregaEquipo>> fetchAll() async => <EntregaEquipo>[];

  @override
  Future<EntregaEquipo> fetchByFolio(int folio) async => _editingEntrega;

  @override
  Future<void> update(int folio, EntregaEquipo entrega) async {}
}

final EntregaEquipo _editingEntrega = EntregaEquipo(
  folio: 42,
  fechaEntrega: DateTime(2026, 8, 25),
  nombreUsuario: 'Persona receptora',
  cargo: 'Cargo de prueba',
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
      descripcion: 'Equipo de prueba',
      marca: 'Marca',
      modelo: 'Modelo',
      serie: 'N/A',
      pesa: 'N/A',
    ),
  ],
);
