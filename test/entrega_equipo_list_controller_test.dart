import 'dart:typed_data';

import 'package:acbmin_site/features/entregas_equipo/data/entrega_equipo_service.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/features/entregas_equipo/presentation/entrega_equipo_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('representa los estados carga, vacío, error y éxito', () async {
    final repository = _FakeRepository();
    final controller = EntregaEquipoListController(repository);

    expect(controller.status, EntregaEquipoListStatus.loading);
    await controller.load();
    expect(controller.status, EntregaEquipoListStatus.empty);

    repository.error = Exception('sin conexión');
    await controller.load();
    expect(controller.status, EntregaEquipoListStatus.error);
    expect(controller.errorMessage, isNotEmpty);

    repository
      ..error = null
      ..items = <EntregaEquipo>[_sampleEntrega(12)];
    await controller.load();
    expect(controller.status, EntregaEquipoListStatus.success);
    expect(controller.visibleItems.single.folio, 12);
  });

  test('filtra localmente y recarga después de un alta con folio', () async {
    final repository = _FakeRepository()
      ..items = <EntregaEquipo>[_sampleEntrega(12)];
    final controller = EntregaEquipoListController(repository);
    await controller.load();

    controller.setSearch('SERIE-12');
    expect(controller.visibleItems, hasLength(1));
    controller.setSearch('no existe');
    expect(controller.visibleItems, isEmpty);

    final created = _sampleEntrega(13);
    repository.items = <EntregaEquipo>[_sampleEntrega(12), created];
    controller.setSearch('');
    await controller.registerCreated(created);
    expect(controller.items.map((item) => item.folio), <int?>[12, 13]);
  });
}

/// Repositorio en memoria que permite cambiar la respuesta en cada escenario.
class _FakeRepository implements EntregaEquipoRepository {
  List<EntregaEquipo> items = <EntregaEquipo>[];
  Object? error;

  @override
  Future<List<EntregaEquipo>> fetchAll() async {
    if (error != null) throw error!;
    return List<EntregaEquipo>.from(items);
  }

  @override
  Future<EntregaEquipo> create(EntregaEquipo entrega) async => entrega;

  @override
  Future<void> delete(int folio) async {
    items.removeWhere((item) => item.folio == folio);
  }

  @override
  Future<EntregaEquipoPdf> downloadPdf(int folio) async => EntregaEquipoPdf(
        bytes: Uint8List(0),
        fileName: 'entrega.pdf',
      );

  @override
  Future<EntregaEquipo> fetchByFolio(int folio) async =>
      items.firstWhere((item) => item.folio == folio);

  @override
  Future<void> update(int folio, EntregaEquipo entrega) async {}
}

EntregaEquipo _sampleEntrega(int folio) => EntregaEquipo(
      folio: folio,
      fechaEntrega: DateTime(2026, 8, 24),
      nombreUsuario: 'Usuario $folio',
      cargo: 'Cargo',
      telefonoExtension: 'N/A',
      direccionArea: 'Área',
      direccionGeneral: 'Dirección',
      subsecretaria: 'Subsecretaría',
      elaboradoPor: 'Elaborador',
      capturadoPor: 'usuario@dominio.mx',
      observaciones: 'Sin observaciones',
      estatus: 'Pendiente',
      equipos: <EquipoEntregado>[
        EquipoEntregado(
          cantidad: 1,
          descripcion: 'Equipo $folio',
          marca: 'Marca',
          modelo: 'Modelo',
          serie: 'SERIE-$folio',
          pesa: 'PESA-$folio',
        ),
      ],
    );
