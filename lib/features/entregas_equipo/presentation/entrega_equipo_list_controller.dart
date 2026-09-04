import 'dart:collection';

import 'package:acbmin_site/features/entregas_equipo/data/entrega_equipo_service.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:flutter/foundation.dart';

/// Estados explícitos que la pantalla del listado puede representar.
enum EntregaEquipoListStatus { loading, empty, error, success }

/// Mantiene carga, búsqueda y errores fuera de los widgets visuales.
class EntregaEquipoListController extends ChangeNotifier {
  EntregaEquipoListController(this._repository);

  final EntregaEquipoRepository _repository;
  final List<EntregaEquipo> _items = <EntregaEquipo>[];

  EntregaEquipoListStatus status = EntregaEquipoListStatus.loading;
  String errorMessage = '';
  String _query = '';

  UnmodifiableListView<EntregaEquipo> get items =>
      UnmodifiableListView<EntregaEquipo>(_items);

  List<EntregaEquipo> get visibleItems => _items
      .where((entrega) => entrega.matchesSearch(_query))
      .toList(growable: false);

  Future<void> load() async {
    status = EntregaEquipoListStatus.loading;
    errorMessage = '';
    notifyListeners();

    try {
      final loaded = await _repository.fetchAll();
      _items
        ..clear()
        ..addAll(loaded);
      status = _items.isEmpty
          ? EntregaEquipoListStatus.empty
          : EntregaEquipoListStatus.success;
    } catch (error) {
      status = EntregaEquipoListStatus.error;
      errorMessage = error is ApiException
          ? error.message
          : 'No fue posible cargar las entregas.';
    }
    notifyListeners();
  }

  void setSearch(String value) {
    _query = value;
    notifyListeners();
  }

  /// Confirma que el alta recibió folio y recarga la fuente oficial.
  Future<void> registerCreated(EntregaEquipo created) async {
    if (created.folio == null) {
      throw const ApiException('El alta no devolvió un folio válido.');
    }
    await load();
  }

  Future<void> deleteByFolio(int folio) async {
    await _repository.delete(folio);
    await load();
  }
}
