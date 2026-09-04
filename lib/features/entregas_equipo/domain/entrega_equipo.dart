/// Renglón de equipo capturado manualmente dentro de una entrega.
///
/// No contiene relaciones con inventario, Resguardos ni Bajas. El [id] solo se
/// recibe del servidor y nunca forma parte de los payloads de alta o edición.
class EquipoEntregado {
  const EquipoEntregado({
    this.id,
    required this.cantidad,
    required this.descripcion,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.pesa,
  });

  final int? id;
  final int cantidad;
  final String descripcion;
  final String marca;
  final String modelo;
  final String serie;
  final String pesa;

  factory EquipoEntregado.fromJson(Map<String, dynamic> json) {
    return EquipoEntregado(
      id: _nullableInt(json['id']),
      cantidad: _requiredInt(json['cantidad'], 'cantidad'),
      descripcion: json['descripcion']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      serie: json['serie']?.toString() ?? '',
      pesa: json['pesa']?.toString() ?? '',
    );
  }

  /// Payload editable exacto; omite deliberadamente el ID asignado por Java.
  Map<String, dynamic> toPayload() => <String, dynamic>{
        'cantidad': cantidad,
        'descripcion': descripcion,
        'marca': marca,
        'modelo': modelo,
        'serie': serie,
        'pesa': pesa,
      };
}

/// Documento de Entrega de Equipo que intercambia el frontend con la API.
class EntregaEquipo {
  const EntregaEquipo({
    this.folio,
    required this.fechaEntrega,
    required this.nombreUsuario,
    required this.cargo,
    required this.telefonoExtension,
    required this.direccionArea,
    required this.direccionGeneral,
    required this.subsecretaria,
    required this.elaboradoPor,
    required this.capturadoPor,
    required this.observaciones,
    this.estatus,
    this.fechaCreacion,
    required this.equipos,
  });

  final int? folio;
  final DateTime fechaEntrega;
  final String nombreUsuario;
  final String cargo;
  final String telefonoExtension;
  final String direccionArea;
  final String direccionGeneral;
  final String subsecretaria;
  final String elaboradoPor;
  final String capturadoPor;
  final String observaciones;
  final String? estatus;
  final DateTime? fechaCreacion;
  final List<EquipoEntregado> equipos;

  factory EntregaEquipo.fromJson(Map<String, dynamic> json) {
    final rawEquipos = json['equipos'];
    if (rawEquipos is! List) {
      throw const FormatException('La respuesta no contiene equipos válidos.');
    }

    return EntregaEquipo(
      folio: _nullableInt(json['folio']),
      fechaEntrega: _requiredDate(json['fechaEntrega'], 'fechaEntrega'),
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      cargo: json['cargo']?.toString() ?? '',
      telefonoExtension: json['telefonoExtension']?.toString() ?? '',
      direccionArea: json['direccionArea']?.toString() ?? '',
      direccionGeneral: json['direccionGeneral']?.toString() ?? '',
      subsecretaria: json['subsecretaria']?.toString() ?? '',
      elaboradoPor: json['elaboradoPor']?.toString() ?? '',
      capturadoPor: json['capturadoPor']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      estatus: json['estatus']?.toString(),
      fechaCreacion: _nullableDate(json['fechaCreacion']),
      equipos: rawEquipos
          .map((item) => EquipoEntregado.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
    );
  }

  /// Representación visual del folio; nunca calcula el siguiente consecutivo.
  String get folioFormateado =>
      folio == null ? 'Sin folio' : folio.toString().padLeft(4, '0');

  /// POST y PUT comparten los campos editables y el arreglo completo de equipos.
  /// Los campos de solo lectura se omiten para que el backend sea su autoridad.
  Map<String, dynamic> toPayload() => <String, dynamic>{
        'fechaEntrega': _formatDate(fechaEntrega),
        'nombreUsuario': nombreUsuario,
        'cargo': cargo,
        'telefonoExtension': telefonoExtension,
        'direccionArea': direccionArea,
        'direccionGeneral': direccionGeneral,
        'subsecretaria': subsecretaria,
        'elaboradoPor': elaboradoPor,
        'capturadoPor': capturadoPor,
        'observaciones': observaciones,
        'equipos': equipos.map((equipo) => equipo.toPayload()).toList(),
      };

  /// Búsqueda local por los campos solicitados en el listado.
  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return folioFormateado.toLowerCase().contains(normalized) ||
        nombreUsuario.toLowerCase().contains(normalized) ||
        equipos.any(
          (equipo) =>
              equipo.serie.toLowerCase().contains(normalized) ||
              equipo.pesa.toLowerCase().contains(normalized) ||
              equipo.descripcion.toLowerCase().contains(normalized),
        );
  }
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime _requiredDate(Object? value, String field) {
  final parsed = _nullableDate(value);
  if (parsed == null) throw FormatException('Fecha inválida en $field.');
  return parsed;
}

DateTime? _nullableDate(Object? value) {
  if (value == null || value.toString().trim().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}

int _requiredInt(Object? value, String field) {
  final parsed = _nullableInt(value);
  if (parsed == null) throw FormatException('Entero inválido en $field.');
  return parsed;
}

int? _nullableInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
